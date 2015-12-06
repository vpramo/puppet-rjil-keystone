#
# Galera setup
# This will work along with db.pp
#

class rjil::galera(
    $galera_role  = 'replica',
    $bind_address = 'localhost',
) {
  ## Setup test code

  rjil::test { 'mysql.sh': }

  $galera_servers = values(service_discover_consul('mysql'))
  $galera_master = values(service_discover_consul('mysql','master'))
  class { '::galera':
	        galera_servers     => $galera_servers,
	        galera_master      => $galera_master,
	        vendor_type        => 'mariadb',
	        configure_firewall => false,
        }

  rjil::jiocloud::consul::service { "mysql":
    tags          => [$galera_role],
    port          => 3306,
    check_command => "/usr/lib/nagios/plugins/check_mysql -H ${bind_address} -u monitor -p monitor"
  }

}
