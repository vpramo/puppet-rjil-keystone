#
# Manifest file for adding pacemaker and corosync
#
class rjil::pacemaker(
  $ipaddress                    = $::ipaddress,
  $enable_secauth               = false,
  $authkey                      = '/etc/corosync/authkey',
  $haproxy_vip_nic              = 'eth1',
  $haproxy_vip_ip               = '192.168.100.29',
  $haproxy_vip_ip_netmask       = '24',
  $haproxy_vip_monitor_interval = '10s'
){

  $unicast_addresses = values(service_discover_consul('haproxy', 'global'))

  class { 'corosync':
    enable_secauth    => $enable_secauth,
    authkey           => $authkey,
    bind_address      => $ipaddress,
    unicast_addresses => $unicast_addresses,
    quorum_members    => $unicast_addresses,
  }

  corosync::service { 'pacemaker':
    version => '0',
  }

  cs_primitive { 'haproxy_vip':
    primitive_class => 'ocf',
    primitive_type  => 'IPaddr2',
    provided_by     => 'heartbeat',
    parameters      => { 'ip' => $haproxy_vip_ip, 'cidr_netmask' => $haproxy_vip_ip_netmask, 'nic' =>$haproxy_vip_nic },
    operations      => { 'monitor' => { 'interval' => $haproxy_vip_monitor_interval } },
  }

  rjil::test::check { 'pacemaker':
  }

}
