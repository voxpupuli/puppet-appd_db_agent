# @api private
# This class handles the configuration.
class appd_db_agent::config
{
  $controller_host_name     = $appd_db_agent::controller_host_name
  $controller_port          = $appd_db_agent::controller_port
  $agent_account_access_key = $appd_db_agent::agent_account_access_key
  $agent_account_name       = $appd_db_agent::agent_account_name
  $controller_ssl_enabled   = $appd_db_agent::controller_ssl_enabled

  $proxy_host     = $appd_db_agent::proxy_host
  $proxy_port     = $appd_db_agent::proxy_port
  $db_agent_name  = $appd_db_agent::db_agent_name
  $java_heap_size = $appd_db_agent::java_heap_size
  $java_home      = $appd_db_agent::java_home
  $user           = $appd_db_agent::user

  file { '/etc/sysconfig/appd_db_agent':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('appd_db_agent/sysconfig.erb'),
  }

  $proxy_java_opts = $proxy_host ? {
    undef   => [],
    default => [
      "-Dappdynamics.http.proxyHost=${proxy_host}",
      "-Dappdynamics.http.proxyPort=${proxy_port}",
    ],
  }

  $db_agent_name_opt = $db_agent_name ? {
    undef   => [],
    default => ["-Ddbagent.name=${db_agent_name}"],
  }

  $heap_size_opts = [
    "-Xms${java_heap_size}",
    "-Xmx${java_heap_size}",
  ]

  $java_opts = concat($proxy_java_opts, $db_agent_name_opt, $heap_size_opts)

  systemd::unit_file { 'appd_db_agent.service':
    content => template('appd_db_agent/systemd.erb'),
  }
}
