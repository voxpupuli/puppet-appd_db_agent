# @summary Downloads, installs, configures and runs an Appdynamics Database Agent service
#
# @param source The source location of the dbagent-x.x.x.x.zip file.  Can be any source that [puppet/archive](https://forge.puppet.com/puppet/archive) supports.
# @param version The version of the agent being installed eg `4.4.1.229`.
# @param controller_host_name The AppDynamics controller to connect to.
# @param controller_port The port on which to connect to the controller.
# @param agent_account_access_key The account access key the agent should use.
# @param user The user to install and run the agent as.
# @param group The primary group of the user.
# @param manage_user Whether to create the user and group.  Useful if you already have puppet code creating an appdynamics user.
# @param agent_account_name This is the account name used to authenticate with the Controller.
# @param controller_ssl_enabled Whether to connect to the controller using SSL.  Needs to be set to `true` if using the AppDynamics SaaS Controller.
# @param checksum Passed to the [puppet/archive](https://forge.puppet.com/puppet/archive) module when downloading the zip.
# @param checksum_type Passed to the [puppet/archive](https://forge.puppet.com/puppet/archive) module when downloading the zip.
# @param proxy_host If specified, the HTTP proxy to use when connecting to the controller.
# @param proxy_port The HTTP proxy port.  Required when proxy_host is set.
# @param db_agent_name The name you want the agent to appear as in the controller.
# @param java_heap_size The heap size for the java process.  The default is very low and should be increased according to how many databases the agent will connect to and in line with the AppDynamics documentation.
# @param java_home The java home of the JRE you want to use.
class appd_db_agent(
  String $source,
  String $version,

  String            $controller_host_name, # TODO: Use Stdlib::Host when stdlib 4.25.0 is released
  Integer[0, 65535] $controller_port,
  String            $agent_account_access_key,

  String            $user                   = 'appdynamics',
  String            $group                  = 'appdynamics',
  Boolean           $manage_user            = true,
  Optional[String]  $agent_account_name     = undef,
  Optional[Boolean] $controller_ssl_enabled = undef,

  Optional[String] $checksum = undef,
  Optional[Enum['md5', 'sha1', 'sha2', 'sha256', 'sha384', 'sha512']] $checksum_type = undef,

  Optional[String]                   $proxy_host     = undef,
  Optional[Integer[0, 65535]]        $proxy_port     = undef,
  Optional[String[1]]                $db_agent_name  = undef,
  Optional[Pattern[/^\d+[kKmMgG]$/]] $java_heap_size = '256m',
  Optional[Stdlib::Unixpath]         $java_home      = '/usr/lib/jvm/java',
)
{
  if $proxy_host {
    assert_type(Integer[0, 65535], $proxy_port) |$expected, $actual| {
      fail('proxy_port must be specified when using proxy_host')
    }
  }

  contain appd_db_agent::install
  contain appd_db_agent::config
  contain appd_db_agent::service

  Class['appd_db_agent::install']
  -> Class['appd_db_agent::config']
  ~> Class['appd_db_agent::service']
}
