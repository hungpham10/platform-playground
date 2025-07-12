import testinfra.utils.ansible_runner
import pytest
import json

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')

def get_instance_ip(host):
    return host.ansible.get_variables()['ansible_default_ipv4']['address']

@pytest.fixture
def database_1_ip(host):
    return get_instance_ip(host.get_host("database-1"))

@pytest.fixture
def database_2_ip(host):
    return get_instance_ip(host.get_host("database-2"))

@pytest.fixture
def database_3_ip(host):
    return get_instance_ip(host.get_host("database-3"))

@pytest.mark.parametrize("pkg", [
    "postgresql",
    "etcd",
    "pgpool2",
    "pmm2-client"
])
def test_packages_installed(host, pkg):
    package = host.package(pkg)
    assert package.is_installed

@pytest.mark.parametrize("instance_name", ["database-1", "database-2", "database-3"])
def test_services_running_on_each_node(host, instance_name):
    instance = host.get_host(instance_name)
    with instance.sudo():
        service = instance.service("postgresql")
        assert service.is_running
        assert service.is_enabled

        service = instance.service("etcd")
        assert service.is_running
        assert service.is_enabled

        service = instance.service("pgpool2")
        assert service.is_running
        assert service.is_enabled

        service = instance.service("pmm-agent")
        assert service.is_running
        assert service.is_enabled

@pytest.mark.parametrize("instance_name", ["database-1", "database-2", "database-3"])
def test_replication_status_on_each_node(host, instance_name):
    instance = host.get_host(instance_name)
    with instance.sudo():
        replication_status = instance.command("psql -U postgres -h localhost -c 'SELECT pg_is_in_recovery();'").stdout
        assert "f" in replication_status or "t" in replication_status

@pytest.mark.parametrize("instance_name", ["database-1", "database-2", "database-3"])
def test_etcd_cluster_health_on_each_node(host, instance_name):
    instance = host.get_host(instance_name)
    with instance.sudo():
        etcd_health = instance.command("etcdctl cluster-health").stdout
        assert "cluster is healthy" in etcd_health

def test_pgpool_status(host):
    with host.sudo():
        pgpool_status = host.command("pcp_node_count -h localhost -U postgres -w").rc
        assert pgpool_status == 0

def test_patroni_cluster_status(host, database_1_ip, database_2_ip, database_3_ip):
    with host.sudo():
        patroni_status = host.command("curl -s http://localhost:8008/cluster").stdout
        patroni_json = json.loads(patroni_status)
        assert patroni_json['state'] == 'running'
        assert patroni_json['leader'] is not None
        assert len(patroni_json['members']) == 3  # Check all 3 nodes are present

        # Verify that the members list contains the expected IPs
        member_ips = [member['host'] for member in patroni_json['members']]
        assert database_1_ip in member_ips
        assert database_2_ip in member_ips
        assert database_3_ip in member_ips

        # Verify roles (leader, replica)
        leader_node = host.get_host(patroni_json['leader'])
        assert leader_node is not None

        for member in patroni_json['members']:
            node = host.get_host(member['name'])
            if member['name'] == patroni_json['leader']:
                # Add assertions to check if the leader is configured correctly
                pass  # Replace with leader-specific checks
            else:
                # Add assertions to check if the replicas are configured correctly
                pass  # Replace with replica-specific checks

def test_replication_status(host):
    with host.sudo():
        replication_status = host.command("psql -U postgres -h localhost -c 'SELECT pg_is_in_recovery();'").stdout
        assert "f" in replication_status or "t" in replication_status

@pytest.mark.parametrize("instance_name", ["database-1", "database-2", "database-3"])
def test_database_connectivity_from_each_node(host, instance_name):
    instance = host.get_host(instance_name)
    with instance.sudo():
        db_connectivity = instance.command("psql -U postgres -h localhost -l").rc
        assert db_connectivity == 0