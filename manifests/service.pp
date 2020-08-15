# @api private
# This class handles the service.
class appd_db_agent::service {
  service { 'appd_db_agent':
    ensure => running,
    enable => true,
  }
}
