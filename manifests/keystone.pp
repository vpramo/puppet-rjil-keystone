#
# profile for configuring keystone role
#
class rjil::keystone(
  $admin_email            = 'root@localhost',
  $public_address         = '0.0.0.0',
  $server_name            = 'localhost',
  $public_port            = '443',
  $public_port_internal   = '5000',
  $admin_port             = '35357',
  $admin_port_internal    = '35357',
  $ssl                    = false,
  $ceph_radosgw_enabled   = false,
  $disable_db_sync        = false,
  $rewrites               = undef,
  $headers                = undef,
  $enable_primary         = true,
  $enable_secondary       = false,
  $server_name_secondary  = 'localhost-secondary',
  $secondary_ssl_cert     = undef,
  $secondary_ssl_key      = undef,
) {

  if $public_address == '0.0.0.0' {
    $address = '127.0.0.1'
  } else {
    $address = $public_address
  }

include rjil::test::keystone

  Rjil::Test::Check {
    ssl     => $ssl,
    address => $address,
  }

  rjil::test::check { 'keystone':
    port => $public_port,
  }

  rjil::test::check { 'keystone-admin':
    port => $admin_port,
  }

  rjil::jiocloud::consul::service { "keystone":
    tags          => ['real'],
    port          => 5000,
  }

  rjil::jiocloud::consul::service { "keystone-admin":
    tags          => ['real'],
    port          => 35357,
  }

  # ensure that we don't even try to configure the
  # database connection until the service is up
  ensure_resource( 'rjil::service_blocker', "$::hostname.galera", {})
  Rjil::Service_blocker["$::hostname.galera"] -> Keystone_config['database/connection']

  if $disable_db_sync {
    Exec <| title == 'keystone-manage db_sync' |> {
      unless => '/bin/true'
    }
  }

  include rjil::apache
  include ::keystone

  if $ceph_radosgw_enabled {
    include rjil::keystone::radosgw
  }

  if $enable_primary{
    ## Configure apache reverse proxy
    apache::vhost { 'keystone':
      servername      => $server_name,
      serveradmin     => $admin_email,
      port            => $public_port,
      ssl             => $ssl,
      docroot         => '/usr/lib/cgi-bin/keystone',
      error_log_file  => 'keystone.log',
      access_log_file => 'keystone.log',
      proxy_pass      => [ { path => '/', url => "http://localhost:${public_port_internal}/"  } ],
      rewrites        => $rewrites,
      headers         => $headers,
    }

    ## Configure apache reverse proxy
    apache::vhost { 'keystone-admin':
      servername      => $server_name,
      serveradmin     => $admin_email,
      port            => $admin_port,
      ssl             => $ssl,
      docroot         => '/usr/lib/cgi-bin/keystone',
      error_log_file  => 'keystone.log',
      access_log_file => 'keystone.log',
      proxy_pass      => [ { path => '/', url => "http://localhost:${admin_port_internal}/"  } ],
      rewrites        => $rewrites,
      headers         => $headers,
    }
  }

  if $enable_secondary {
    ## Configure apache reverse proxy
    ## Using serveralias instead of setting new vhosts would cause SSL error
    apache::vhost { 'keystone-secondary':
      servername      => $server_name_secondary,
      serveradmin     => $admin_email,
      port            => $public_port,
      ssl             => $ssl,
      docroot         => '/usr/lib/cgi-bin/keystone',
      error_log_file  => 'keystone-secondary.log',
      access_log_file => 'keystone-secondary.log',
      proxy_pass      => [ { path => '/', url => "http://localhost:${public_port_internal}/"  } ],
      rewrites        => $rewrites,
      headers         => $headers,
      ssl_cert        => $secondary_ssl_cert,
      ssl_key         => $secondary_ssl_key,
    }

    ## Configure apache reverse proxy
    apache::vhost { 'keystone-admin-secondary':
      servername      => $server_name_secondary,
      serveradmin     => $admin_email,
      port            => $admin_port,
      ssl             => $ssl,
      docroot         => '/usr/lib/cgi-bin/keystone',
      error_log_file  => 'keystone-secondary.log',
      access_log_file => 'keystone-secondary.log',
      proxy_pass      => [ { path => '/', url => "http://localhost:${admin_port_internal}/"  } ],
      rewrites        => $rewrites,
      headers         => $headers,
      ssl_cert        => $secondary_ssl_cert,
      ssl_key         => $secondary_ssl_key,
    }
  }
  Class['rjil::keystone'] -> Rjil::Service_blocker<| title == 'keystone-admin' |>

  $keystone_logs = ['keystone-manage',
                    'keystone-all',
                    ]
  rjil::jiocloud::logrotate { $keystone_logs:
    logdir => '/var/log/keystone'
  }

}
