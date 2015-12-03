# Class: moxi:package
#
class moxi::package (
  $rpmlocation,
  $rpmbasename,
  $options,
) {

  if $::osfamily == 'Gentoo' {

    # Ugly as hell
    exec { "install-${rpmbasename}-rpm":
      command => "mkdir moxi; cd moxi && wget -q ${rpmlocation}/${rpmbasename}.rpm && rpm2tar ${rpmbasename}.rpm && tar xf ${rpmbasename}.tar && mv opt/moxi /opt/moxi && chown -R moxi: /opt/moxi; rm -rf /tmp/moxi",
      creates => '/opt/moxi',
      cwd     => '/tmp',
      path    => [ '/bin', '/usr/bin' ],
      require => [
        User['moxi'],
        Package['app-arch/rpm2targz'],
      ],
    }

    file { '/etc/init.d/moxi-server':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("${module_name}/gentoo/moxi-server-init.erb"),
      require => Exec["install-${rpmbasename}-rpm"],
      notify  => Service['moxi-server'],
    }
    file { '/etc/conf.d/moxi-server':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "BASEDIR=\"/opt/moxi\"\nPIDFILE=\"/opt/moxi/moxi.pid\"\nOPTIONS=\"${options}\"\n",
      require => Exec["install-${rpmbasename}-rpm"],
      notify  => Service['moxi-server'],
    }

  } elsif $::osfamily == 'RedHat' and versioncmp($::operatingsystemrelease, '7') >= 0 {

    # Much much cleaner
    package { 'moxi-server':
      ensure => installed,
      before => User['moxi'],
    }

    file { '/etc/systemd/system/moxi-server.service':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/moxi-server.service.erb"),
      require => Package['moxi-server'],
      notify  => Service['moxi-server'],
    }

  } else {

    # Much much cleaner
    package { 'moxi-server':
      ensure => installed,
      before => User['moxi'],
    }

    file { '/opt/moxi/etc/moxi-init.d':
      owner   => 'bin',
      group   => 'bin',
      mode    => '0755',
      source  => "puppet:///modules/${module_name}/moxi-init.d",
      require => Package['moxi-server'],
      notify  => Service['moxi-server'],
    }
    file { '/etc/sysconfig/moxi-server':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "OPTIONS=\"${options}\"\n",
      notify  => Service['moxi-server'],
    }

  }

}

