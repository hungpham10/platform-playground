import testinfra.utils.ansible_runner
import pytest
import json
import time
import random

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')

@pytest.mark.parametrize("pkg", [
    "postgresql",
    "etcd",
    "pgpool2",
    "pmm2-client"
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

def test_etcd_cluster_health(host):
    with host.sudo():
        etcd_health = host.command("etcdctl cluster-health").stdout
        assert "cluster is healthy" in etcd_health

def test_pgpool_status(host):
    with host.sudo():
        pgpool_status = host.command("pcp_node_count -h localhost -U postgres -w").rc
        assert pgpool_status == 0

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

def test_patroni_failover(host):
    # Get the current leader
    patroni_json = get_patroni_cluster_status(host)
    leader_name = patroni_json['leader']
    leader_host = host.get_host(leader_name)

    # Choose a random node to act as the client
    client_host = host.get_host(random.choice(testinfra_hosts))

    # Create a function to test database connectivity from the client
    def check_db_connectivity(client):
        with client.sudo():
            db_check = client.command("psql -U postgres -h localhost -c 'SELECT 1;'").rc
            return db_check == 0

    # Verify initial database connectivity from the client
    assert check_db_connectivity(client_host), "Initial database connectivity failed"

    # Stop the Patroni service on the leader
    with leader_host.sudo():
        leader_host.service("patroni").stop()
        time.sleep(30)  # Wait for failover to complete

    # Verify that a new leader is elected
    new_patroni_json = get_patroni_cluster_status(host)
    assert new_patroni_json['state'] == 'running'
    assert new_patroni_json['leader'] is not None
    assert new_patroni_json['leader'] != leader_name
    assert len(new_patroni_json['members']) == 3

    # Verify that the cluster is still healthy
    etcd_health = host.command("etcdctl cluster-health").stdout
    assert "cluster is healthy" in etcd_health

    # Verify database connectivity from the client after failover
    assert check_db_connectivity(client_host), "Database connectivity failed after failover"

    # Start the Patroni service on the old leader
    with leader_host.sudo():
        leader_host.service("patroni").start()
        time.sleep(30)  # Wait for the node to rejoin the cluster

    # Verify that all members are present after rejoin
    final_patroni_json = get_patroni_cluster_status(host)
    assert final_patroni_json['state'] == 'running'
    assert len(final_patroni_json['members']) == 3

    # Verify database connectivity from the client after rejoin
    assert check_db_connectivity(client_host), "Database connectivity failed after rejoin"
