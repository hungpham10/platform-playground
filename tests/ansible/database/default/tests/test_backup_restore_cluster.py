import testinfra.utils.ansible_runner
import pytest
import json
import time
import os

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')

@pytest.mark.parametrize("pkg", [
    "postgresql",
    "etcd",
    "pgpool2",
    "pmm2-client",
    "pgbackrest"  # Assuming you're using pgbackrest
])
def test_packages_installed(host, pkg):
    package = host.package(pkg)
    assert package.is_installed

def test_services_running(host):
    service = host.service("postgresql")
    assert service.is_running
    assert service.is_enabled

    service = host.service("etcd")
    assert service.is_running
    assert service.is_enabled

    service = host.service("pgpool2")
    assert service.is_running
    assert service.is_enabled

    service = host.service("pmm-agent")
    assert service.is_running
    assert service.is_enabled

def get_patroni_cluster_status(host):
    with host.sudo():
        patroni_status = host.command("curl -s http://localhost:8008/cluster").stdout
        return json.loads(patroni_status)

def test_patroni_cluster_status(host):
    patroni_json = get_patroni_cluster_status(host)
    assert patroni_json['state'] == 'running'
    assert patroni_json['leader'] is not None
    assert len(patroni_json['members']) == 3  # Check all 3 nodes are present

def test_database_connectivity(host):
    with host.sudo():
        db_connectivity = host.command("psql -U postgres -h localhost -l").rc
        assert db_connectivity == 0

def test_replication_status(host):
    with host.sudo():
        replication_status = host.command("psql -U postgres -h localhost -c 'SELECT pg_is_in_recovery();'").stdout
        assert "f" in replication_status or "t" in replication_status

def test_backup_restore_cluster(host):
    # Choose a node to perform the backup
    backup_host = host.get_host(testinfra_hosts[0])

    # Define backup directory
    backup_dir = "/tmp/backup"

    # Create backup directory
    with backup_host.sudo():
        backup_host.command(f"mkdir -p {backup_dir}")

    # Take a backup
    with backup_host.sudo():
        backup_command = f"pgbackrest --stanza=db backup --type=full"
        backup_result = backup_host.command(backup_command)
        assert backup_result.rc == 0, f"Backup failed: {backup_result.stderr}"

    # Simulate a disaster: remove the data directory on all nodes
    for h in testinfra_hosts:
        data_host = host.get_host(h)
        with data_host.sudo():
            data_host.command("systemctl stop postgresql") # Stop postgresql before removing data
            data_host.command("rm -rf /var/lib/postgresql/14/main") # Adjust path if needed
            data_host.command("systemctl start postgresql") # Start postgresql after removing data

    # Restore the backup on all nodes
    for h in testinfra_hosts:
        restore_host = host.get_host(h)
        with restore_host.sudo():
            restore_command = f"pgbackrest --stanza=db restore --delta"
            restore_result = restore_host.command(restore_command)
            assert restore_result.rc == 0, f"Restore failed: {restore_result.stderr}"

    # Start Patroni on all nodes
    for h in testinfra_hosts:
        patroni_host = host.get_host(h)
        with patroni_host.sudo():
            patroni_host.command("systemctl start patroni")

    # Wait for the cluster to recover
    time.sleep(60)

    # Verify that the cluster is healthy
    test_patroni_cluster_status(host)
    test_database_connectivity(host)
    test_replication_status(host)