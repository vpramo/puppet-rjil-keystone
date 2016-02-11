Exec {
  path      => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/", "/usr/local/bin/", "/usr/local/sbin/"],
  logoutput => true
}

#
# bootstrap node mainly for consul purposes (optional)
# Presently Haproxy1 is also the bootstrap node
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
  include rjil::galera
  include rjil::commonservices::omdclient
}

#
# The main IAM nodes
# These also have a haproxy which is used only by localhost
# for accessing galera cluster
#

node /^iam\d+/ {
  include rjil::base
  include rjil::haproxy
  include rjil::keystone
  include rjil::haproxy::galera
  include openstack_extras::client
  include openstack_extras::auth_file
  include rjil::commonservices::omdclient
}

#
# Haproxy nodes
# This is used to load balance only IAM calls.
#

node /^iamhaproxy\d+/ {
  include rjil::base
  include rjil::haproxy
  include rjil::haproxy::openstack
  include rjil::jiocloud::consul::consul_alerts
  include openstack_extras::client
  include openstack_extras::auth_file
  include rjil::commonservices::omdclient
  include rjil::pacemaker
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
