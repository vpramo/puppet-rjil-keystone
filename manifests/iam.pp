## Class for standalone IAM
class rjil::iam(){
  include rjil::keystone
  
  rjil::jiocloud::dns::entry {"$::keystone_public_address":
      $cname = $::fqdn,
  } -> Class['rjil::keystone']
  
}
