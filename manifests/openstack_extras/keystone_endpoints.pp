#
# Overwrite for default openstack_extras::keystone_endpoints
# The module creates endpoints for all services
# whereas we want endpoint only for keystone presently
#
class rjil::openstack_extras::keystone_endpoints(
    $dummy_arg = 'dummy_arg'
){
  include ::keystone::endpoint
  include ::keystone::roles::admin
}
