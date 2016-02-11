#
# Class: rjil::haproxy::galera
#   Setup mysql in haproxy.
#
class rjil::haproxy::galera(
  $keystone_ips          = sort(values(service_discover_consul('keystone', 'real'))),
  $galera_ips            = sort(values(service_discover_consul('mysql', 'node'))),
  $galera_port            = '3306',
) {



  Rjil::Haproxy_service {
    ssl => true,
  }

  rjil::haproxy_service { 'mysql':
    balancer_ports    => $galera_port,
    cluster_addresses => $galera_ips,
    check_type        => 'mysql'
  }
	rjil::test::check { 'galera':
	  port    => $galera_port,
	  ssl     => false,
	  type    => 'galera',
	 }

  rjil::jiocloud::consul::service { 'galera':
    tags           => ["$::hostname"],
    port           => $port,
  }

}
