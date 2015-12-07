#
# Class: rjil::haproxy::openstack
#   Setup openstack services in haproxy.
#
class rjil::haproxy::openstack(
  $horizon_ips           = sort(values(service_discover_consul('horizon', 'real'))),
  $keystone_ips          = sort(values(service_discover_consul('keystone', 'real'))),
  $keystone_internal_ips = sort(values(service_discover_consul('keystone-admin', 'real'))),
  $glance_ips            = sort(values(service_discover_consul('glance', 'real'))),
  $cinder_ips            = sort(values(service_discover_consul('cinder', 'real'))),
  $nova_ips              = sort(values(service_discover_consul('nova', 'real'))),
  $neutron_ips           = sort(values(service_discover_consul('neutron', 'real'))),
  $radosgw_ips           = sort(values(service_discover_consul('radosgw', 'real'))),
  $galera_ips            = sort(values(service_discover_consul('mysql', 'node'))),
  $radosgw_port          = '80',
  $horizon_port          = '80',
  $horizon_https_port    = '443',
  $novncproxy_port       = '6080',
  $keystone_public_port  = '5000',
  $keystone_admin_port   = '35357',
  $glance_port           = '9292',
  $glance_registry_port  = '9191',
  $cinder_port           = '8776',
  $nova_port             = '8774',
  $neutron_port          = '9696',
  $metadata_port         = '8775',
  $nova_ec2_port         = '8773',
  $galera_port            = '3306',
) {

  class { 'rjil::test::haproxy_openstack':
    keystone_ips          => $keystone_ips,
  }

  Rjil::Haproxy_service {
    ssl => true,
  }


  rjil::haproxy_service { 'keystone':
    balancer_ports    => $keystone_public_port,
    cluster_addresses => $keystone_ips,
  }

  rjil::haproxy_service { 'keystone-admin':
    balancer_ports    => $keystone_admin_port,
    cluster_addresses => $keystone_internal_ips,
  }

  rjil::haproxy_service { 'mysql':
    balancer_ports    => $galera_port,
    cluster_addresses => $galera_ips,
  }

}
