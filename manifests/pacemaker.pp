#
# Manifest file for adding pacemaker and corosync
#
class rjil::pacemaker(
  $ipaddress          = $::ipaddress,
  $enable_secauth     = true,
  $authkey            = '/var/lib/puppet/ssl/certs/ca.pem',
  $unicast_addresses  = [],

){

  $unicast_addresses = values(service_discover_consul('haproxy', 'global'))

	class { 'corosync':
	  enable_secauth    => $enable_secauth,
	  authkey           => $authkey,
	  bind_address      => $ipaddress,
	  unicast_addresses => $unicast_addresses,
	}

	corosync::service { 'pacemaker':
    version => '0',
  }

	cs_primitive { 'haproxy_vip':
	  primitive_class => 'ocf',
	  primitive_type  => 'IPaddr2',
	  provided_by     => 'heartbeat',
	  parameters      => { 'ip' => '192.168.100.29', 'cidr_netmask' => '23' },
	  operations      => { 'monitor' => { 'interval' => '10s' } },
	}
}
