#
# Galera setup
# This will work along with db.pp
#

class rjil::galera(
    $dummy_arg = 'dummyarg',
) {
    $galera_servers = values(service_discover_consul('mysql'))
    $galera_master = values(service_discover_consul('mysql','master'))
    class { '::galera':
        galera_servers => $galera_servers,
        galera_master  => $galera_master,
        vendor_type    => 'mariadb',
    }
}
