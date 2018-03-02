# @api private
# This class handles the installation.
class appd_db_agent::install
{
  $version       = $::appd_db_agent::version
  $source        = $::appd_db_agent::source
  $checksum      = $::appd_db_agent::checksum
  $checksum_type = $::appd_db_agent::checksum_type

  $user  = $::appd_db_agent::user
  $group = $::appd_db_agent::group

  $manage_user = $::appd_db_agent::manage_user

  include java

  if $manage_user {
    group { $group:
      ensure => present,
    }
    user { $user:
      ensure     => present,
      gid        => $group,
      home       => '/opt/appdynamics',
      managehome => false,
      shell      => '/sbin/nologin',
      system     => true,
    }
  }

  file { '/opt/appdynamics':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0640',
  }

  file { "/opt/appdynamics/dbagent-${version}":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0640',
  }

  archive { "/tmp/dbagent-${version}.zip":
    ensure       => present,
    source       => $source,
    extract      => true,
    extract_path => "/opt/appdynamics/dbagent-${version}",
    creates      => "/opt/appdynamics/dbagent-${version}/db-agent.jar",
    cleanup      => true,
    user         => $user,
    group        => $group,
    require      => File["/opt/appdynamics/dbagent-${version}"],
  }

  file { '/opt/appdynamics/dbagent':
    ensure => link,
    owner  => $user,
    group  => $group,
    target => "/opt/appdynamics/dbagent-${version}",
    mode   => '0640',
  }
}
