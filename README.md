# puppet/appd\_db\_agent

[![License](https://img.shields.io/github/license/voxpupuli/puppet-appd_db_agent.svg)](https://github.com/voxpupuli/puppet-appd_db_agent/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/voxpupuli/puppet-appd_db_agent.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-appd_db_agent)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/appd_db_agent.svg)](https://forge.puppetlabs.com/puppet/appd_db_agent)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/appd_db_agent.svg)](https://forge.puppetlabs.com/puppet/appd_db_agent)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/appd_db_agent.svg)](https://forge.puppetlabs.com/puppet/appd_db_agent)

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with appd\_db\_agent](#setup)
    * [What appd\_db\_agent affects](#what-appd\_db\_agent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with appd\_db\_agent](#beginning-with-appd\_db\_agent)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs, configures and provides a systemd based service for the [AppDynamics Database Agent](https://docs.appdynamics.com/display/PRO44/Database+Visibility).
It has been developed and tested with dbagent version 4.4.1.229 on CentOS 7 with Puppet 4.10.
It should also work on Puppet 5 and on other RedHat Enterprise 7 clones.

Configuration is all done via the systemd service and environment file it loads from `/etc/sysconfig/appd_db_agent`.
No changes are made to `controller-info.xml`.

## Setup

### What appd\_db\_agent affects

The module downloads and installs the database agent under `/opt/appdynamics`.
It creates a systemd unit file for the agent and starts the service.

The agent depends on java being installed and this module will install by
including `puppetlabs/java`.

### Setup Requirements

AppDynamics doesn't provide an anonymous download link for the agent.
You will have to provide the dbagent zip yourself. You have several choices for hosting it yourself.
You could make it available over http via an artifact repository such as Artifactory or Nexus.
Or you could make it available using your puppetserver's fileserver by placing the zip in your site module
and specifying a `puppet:///` url as the `source` parameter.

If using an onsite AppDynamics controller,
you will have to install the required license on your controller before the agent will work.

### Beginning with appd\_db\_agent

The module has a single public class.  There are several optional parameters, but 5 that are required.  You will need to know

* The source for the dbagent zip file.
  This can be any source the puppet/archive module supports such as a https URL, a local file, or a `puppet:///` URL.
* The version of the dbagent you're installing.
  This isn't automatically extracted from the source URL.  It should be the complete version number eg `4.4.1.2`.
* The controller host name.
  The module should work with local and hosted AppDynamics controllers.
* The controller port number.
  If using the hosted service, this will be 443.
* The password to use as the Agent Account Access Key.

You should also consider how much heap space to allocate to the JVM running the agent.  This module defaults the parameter `java_heap_size` to just 256MB.
AppDynamic's [recommend](https://docs.appdynamics.com/display/PRO44/Database+Visibility+System+Requirements) 1GB + 512MB for each monitored database.
## Usage

A minimal example where the agent zip is stored in a `site` module and a locally installed controller is used.

```puppet
class { 'appd_db_agent':
  source                   => 'puppet:///modules/site/appdynamics/dbagent-4.4.1.229.zip',
  version                  => '4.4.1.229',
  controller_host_name     => 'appdynamics.example.com',
  controller_port          => 8090,
  agent_account_access_key => 'secret',
}
```

A more complete example using Artifactory as the source for the zip.
Communications with the hosted SAAS is encrypted and via a squid proxy.

```puppet
class { 'appd_db_agent':
  source                   => 'https://artifactory.example.com/artifactory/infra/org/appdynamics/dbagent/dbagent-4.4.1.229.zip',
  checksum                 => artifactory_sha1('https://artifactory.example.com/artifactory/api/storage/infra/org/appdynamics/dbagent/dbagent-4.4.1.229.zip'),
  checksum_type            => 'sha1',
  version                  => '4.4.1.229',
  controller_host_name     => 'exampleorg.saas.appdynamics.com',
  controller_port          => 443,
  controller_ssl_enabled   => true,
  agent_account_access_key => 'secret',
  proxy_host               => 'squid.example.com',
  proxy_port               => 3128,
  java_heap_size           => '4g',
}
```

## Reference

[Puppet Strings REFERENCE.md](REFERENCE.md)

## Limitations

* Tested on CentOS 7
* Puppet 4.10 or greater.

## Development

This module is maintained by [Vox Pupuli](https://voxpupuli.org). It was written by [Alex Fisher](https://github.com/alexjfisher) and is licensed under the Apache-2.0 License.
