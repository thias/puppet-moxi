# Class: moxi
#
# Moxi Server. Everything is kept in /opt/moxi as this is where the upstream
# rpm package puts everything. Arguably ugly indeed.
#
# Parameters:
#  $options:
#    Additional command-line moxi options. Default: none
#  $cluster_url:
#    Membase cluster URL. Mandatory.
#  $usr:
#    Optional Membase user. Default: no auth
#  $pwd:
#    Optional Membase password. Default: no auth
#  $port_listen:
#    Local port to listen on. Default: '11211'
#  $default_bucket_name:
#    Name of the default bucket. Default: 'default'
#  $downstream_max,
#  $downstream_conn_max,
#  $downstream_conn_queue_timeout,
#  $downstream_timeout,
#  $wait_queue_timeout,
#  $connect_max_errors,
#  $connect_retry_interval,
#  $connect_timeout,
#  $auth_timeout,
#  $cycle:
#    Other Moxi parameters. See documentation.
#
# Sample Usage :
#  include moxi
#
class moxi (
  # init.d/moxi options - see moxi -h
  $options = '',
  $cron_restart = false,
  $cron_restart_hour = '04',
  $cron_restart_minute = fqdn_rand(60),
  $auto_restart = false,
  # moxi-cluster.cfg options
  $cluster_url,
  # moxi.cfg options
  $usr = false,
  $pwd = false,
  $port_listen = '11211',
  $default_bucket_name = 'default',
  $downstream_max = '1024',
  $downstream_conn_max = '4',
  $downstream_conn_queue_timeout = '200',
  $downstream_timeout = '5000',
  $wait_queue_timeout = '200',
  $connect_max_errors = '5',
  $connect_retry_interval = '30000',
  $connect_timeout = '400',
  $auth_timeout = '100',
  $cycle = '200',
) {

  package { 'moxi-server':
    ensure => 'installed',
    before => User['moxi'],
  }

  if $::osfamily == 'RedHat' and versioncmp($::operatingsystemrelease, '7') >= 0 {

    # The upstream rpm is made for RHEL6, switch it to native systemd
    rhel::systemd::service { 'moxi-server':
      source => "puppet:///modules/${module_name}/moxi-server.service",
      notify => Service['moxi-server'],
    }
    file { '/etc/systemd/system/moxi-server.service.d':
      ensure  => 'directory',
      purge   => true,
      recurse => true,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
    if $auto_restart {
      file { '/etc/systemd/system/moxi-server.service.d/auto-restart.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "[Service]\nRestart=on-failure\n",
        notify  => Exec['systemctl daemon-reload'],
      }
    }

  } else {

    file { '/opt/moxi/etc/moxi-init.d':
      owner   => 'bin',
      group   => 'bin',
      mode    => '0755',
      source  => "puppet:///modules/${module_name}/moxi-init.d",
      require => Package['moxi-server'],
      notify  => Service['moxi-server'],
    }

  }

  file { '/etc/sysconfig/moxi-server':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "OPTIONS=\"${options}\"\n",
    notify  => Service['moxi-server'],
  }

  # The main configuration files
  file { '/opt/moxi/etc/moxi.cfg':
    owner   => 'moxi',
    group   => 'moxi',
    content => template("${module_name}/moxi.cfg.erb"),
    require => Package['moxi-server'],
    notify  => Service['moxi-server'],
  }
  file { '/opt/moxi/etc/moxi-cluster.cfg':
    owner   => 'moxi',
    group   => 'moxi',
    content => template("${module_name}/moxi-cluster.cfg.erb"),
    require => Package['moxi-server'],
    notify  => Service['moxi-server'],
  }

  # We make the directory writeable by moxi so that we can dump pid, log,
  # sock... ugly, yeah.
  # Don't use 'file' since the resource would then be the parent of others,
  # and create a dependency loop... also ugly, yup.
  exec { 'chown moxi:moxi /opt/moxi':
    unless  => 'test -d /opt/moxi && [ "`stat -c %U:%G /opt/moxi`" == "moxi:moxi" ]',
    path    => [ '/bin', '/usr/bin' ],
    require => Package['moxi-server'],
    before  => Service['moxi-server'],
  }
  exec { 'chmod 755 /opt/moxi':
    unless  => 'test -d /opt/moxi && [ "`stat -c %a /opt/moxi`" == "755" ]',
    path    => [ '/bin', '/usr/bin' ],
    require => Package['moxi-server'],
    before  => Service['moxi-server'],
  }
  file { '/etc/logrotate.d/moxi':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/logrotate.d/moxi.erb"),
  }

  # The package should take care of the user, this will tweak if needed
  user { 'moxi':
    comment => 'Moxi system user',
    home    => '/opt/moxi',
    shell   => '/sbin/nologin',
    system  => true,
  }

  service { 'moxi-server':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }

  if $cron_restart {
    cron { 'moxi-restart':
      command => '/sbin/service moxi-server restart >/dev/null',
      user    => 'root',
      hour    => $cron_restart_hour,
      minute  => $cron_restart_minute,
    }
  } else {
    cron { 'moxi-restart':
      ensure => 'absent',
      user   => 'root',
    }
  }

}
