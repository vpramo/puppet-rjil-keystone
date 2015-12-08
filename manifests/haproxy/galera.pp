#
# Class: rjil::haproxy::galera
#   Setup mysql in haproxy.
#
class rjil::haproxy::galera(
  $keystone_ips          = sort(values(service_discover_consul('keystone', 'real'))),
  $galera_ips            = sort(values(service_discover_consul('mysql', 'node'))),
  $galera_port            = '3306',
) {

  class { 'rjil::test::haproxy_openstack':
    keystone_ips          => $keystone_ips,
  }

  Rjil::Haproxy_service {
    ssl => true,
  }

  rjil::haproxy_service { 'mysql':
    balancer_ports    => $galera_port,
    cluster_addresses => $galera_ips,
    check_type        => 'mysql'
  }

  rjil::jiocloud::consul::service { 'galera':
    tags           => ["$::hostname"],
    port           => $port,
    check_command => '/usr/lib/jiocloud/tests/service_checks/mysql.sh'
  }

}
