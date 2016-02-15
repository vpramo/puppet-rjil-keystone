#
# Galera setup
# This will work along with db.pp
#

class rjil::galera(
  $galera_role            = 'replica',
  $mysql_max_connections  = 1024,
  $dbs                    = {},
  $bind_address           = '0.0.0.0',
  $galera_master_hostname = 'iamdb1',
) {
  ## Setup test code

  rjil::test { 'mysql.sh': }


  ## Call db_def to create databases, users and grants
  create_resources('rjil::db::instance', $dbs)

  $galera_servers = values(service_discover_consul('mysql', 'node'))
  if ($galera_master_hostname in $::fqdn){
    $galera_master = $::fqdn
  } else {
    $galera_master = $galera_master_hostname
  }
  class { '::galera':
    galera_servers     => $galera_servers,
    galera_master      => $galera_master,
    vendor_type        => 'mariadb',
    configure_firewall => false,
    override_options   => { 'mysqld' => {
                                          'max_connections' => $mysql_max_connections,
                                          'bind-address'    => $bind_address,
                                          'wsrep_causal_reads' => '1',
                                        }
                          },
  }

  if ($bind_address == '0.0.0.0') {
    $user_address = '127.0.0.1'
  } else {
    $user_address = $bind_address
  }

  mysql_user { "monitor@${user_address}":
    ensure        => 'present',
    password_hash => mysql_password('monitor'),
    require       => File['/root/.my.cnf'],
  }

  mysql_grant { "monitor@${user_address}/*.*":
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['USAGE'],
    user       => "monitor@${user_address}",
    table      => '*.*',
    require    => Mysql_user["monitor@${user_address}"],
  }


  rjil::jiocloud::consul::service { "mysql":
    tags          => [$galera_role, "node"],
    port          => 3306,
    check_command => "/usr/lib/nagios/plugins/check_mysql -H ${bind_address} -u monitor -p monitor"
  }

  # make sure that we install mysql before our service blocker starts for the
  # case where they are on the same machine

  Class['rjil::galera'] -> Rjil::Service_blocker<| title == 'mysql' |>

}
