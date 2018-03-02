# Reference

## Classes
### Public Classes
* [`appd_db_agent`](#appd_db_agent): Downloads, installs, configures and runs an Appdynamics Database Agent service
### Private Classes
* `appd_db_agent::config`: This class handles the configuration.
* `appd_db_agent::install`: This class handles the installation.
* `appd_db_agent::service`: This class handles the service.
## Classes

### appd_db_agent

Downloads, installs, configures and runs an Appdynamics Database Agent service


#### Parameters

The following parameters are available in the `appd_db_agent` class.

##### `source`

Data type: `String`

The source location of the dbagent-x.x.x.x.zip file.  Can be any source that puppet/archive supports.

##### `version`

Data type: `String`

The version of the agent being installed eg `4.4.1.229`.

##### `controller_host_name`

Data type: `String`

The AppDynamics controller to connect to.

##### `controller_port`

Data type: `Integer[0, 65535]`

The port on which to connect to the controller.

##### `agent_account_access_key`

Data type: `String`

The account access key the agent should use.

##### `user`

Data type: `String`

The user to install and run the agent as.

Default value: 'appdynamics'

##### `group`

Data type: `String`

The primary group of the user.

Default value: 'appdynamics'

##### `manage_user`

Data type: `Boolean`

Whether to create the user and group.  Useful if you already have puppet code creating an appdynamics user.

Default value: `true`

##### `agent_account_name`

Data type: `Optional[String]`

This is the account name used to authenticate with the Controller.

Default value: `undef`

##### `controller_ssl_enabled`

Data type: `Optional[Boolean]`

Whether to connect to the controller using SSL.  Needs to be set to `true` if using the AppDynamics SaaS Controller.

Default value: `undef`

##### `checksum`

Data type: `Optional[String]`

Passed to the puppet/archive module when downloading the zip.

Default value: `undef`

##### `checksum_type`

Data type: `Optional[Enum['md5', 'sha1', 'sha2', 'sha256', 'sha384', 'sha512']]`

Passed to the puppet/archive module when downloading the zip.

Default value: `undef`

##### `proxy_host`

Data type: `Optional[String]`

If specified, the HTTP proxy to use when connecting to the controller.

Default value: `undef`

##### `proxy_port`

Data type: `Optional[Integer[0, 65535]]`

The port HTTP proxy port.  Required when proxy_host is set.

Default value: `undef`

##### `db_agent_name`

Data type: `Optional[String[1]]`

The name you want the agent to appear as in the controller.

Default value: `undef`

##### `java_heap_size`

Data type: `Optional[Pattern[/^\d+[kKmMgG]$/]]`

The heap size for the java process.  The default is very low and should be increased according to how many databases the agent will connect to and in line with the AppDynamics documentation.

Default value: '256m'

##### `java_home`

Data type: `Optional[Stdlib::Unixpath]`

The java home of the JRE you want to use.

Default value: '/usr/lib/jvm/java'


