#
# Overwrite for default openstack_extras::keystone_endpoints
# The module creates endpoints for all services
# whereas we want endpoint only for keystone presently
#
class rjil::openstack_extras::keystone_endpoints(
    $dummy_arg = 'dummy_arg'
){
# TODO: Fix this!!
# Could not prefetch keystone_endpoint provider 'openstack':
# Execution of '/usr/bin/openstack endpoint list --quiet --format csv --long' returned 2: usage: 
# openstack endpoint list [-h] [-f {csv,html,json,table,yaml}]

#  include ::keystone::endpoint
  include ::keystone::roles::admin
}
