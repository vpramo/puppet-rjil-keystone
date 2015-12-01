Exec {
  path      => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/", "/usr/local/bin/", "/usr/local/sbin/"],
  logoutput => true
}

#
# bootstrap node mainly for consul purposes
# 
node /^iambootstrap\d+/ {
  include rjil::base
  include rjil::jiocloud::consul::consul_alerts
}




#
# This contains the galera db master. 
# Presently master and slave are decided based on node number:
# i.e, 1 - master
#      2 - slave
# In the future, on further scaling up, this node-role mapping can be hashed or stored.
#
node /^iamdb\d+/ {
  include rjil::base
  include rjil::memcached
  include openstack_extras::client
  include rjil::db
  include rjil::openstack_zeromq
  include rjil::openstack_objects
}

#
# The main iam nodes
#

node /^iam\d+/ {
  include rjil::base
  include rjil::keystone
  include openstack_extras::client
  include rjil::openstack_zeromq
  include rjil::openstack_objects
}

#
# Haproxy nodes
# Presently this haproxy cluster will be haproxy for both iam as well as galera cluster
#

node /^iamhaproxy\d+/ {
  include rjil::base
  include rjil::haproxy
  include rjil::haproxy::openstack
}

# 
# httproxy node for providing the http proxy.
# 

node /^httpproxy\d+/ {
  include rjil::base
  include rjil::http_proxy

  dnsmasq::conf { 'google':
    ensure  => present,
    content => 'server=8.8.8.8',
  }
  include rjil::jiocloud::vagrant::dhcp
}

#
# For running vagrant setups
#

node /^vagrant\d+/ {
  include rjil::base
  include rjil::jiocloud::vagrant
}

