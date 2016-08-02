# Class: lsyncd
#
# lsyncd.
#
# Sample Usage :
#  class { 'lsyncd': config_source => 'puppet:///modules/example/lsyncd.conf' }
#
class lsyncd (
  $config_source   = undef,
  $config_content  = undef,
  $logdir_owner    = 'root',
  $logdir_group    = 'root',
  $logdir_mode     = '0755',
  $lsyncd_options  = undef,
  # This parameter requires a modified rpm init script
  $lsyncd_user     = undef,
  $config_path     = $lsyncd::params::config_path,
  $config_file     = $lsyncd::params::config_file,
  $csync2_sources  = undef,
) inherits lsyncd::params {

  package { 'lsyncd': ensure => 'installed' }

  # validate values supplied
  validate_absolute_path($config_path)

  # Create the configuration base path
  if $::osfamily =~ /(Debian|Ubuntu)/ {
    file { $config_path:
      ensure => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

  if ($csync2_sources) {
    $_content = template('lsyncd/lsyncd-csync2.conf.erb')
  } else {
    $_content = $config_content
  }

  service { 'lsyncd':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    require   => Package['lsyncd'],
  }

  file { $config_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $config_source,
    content => $_content,
    require => Package['lsyncd'],
    notify  => Service['lsyncd'],
  }

  # Debian does not support/require additional configuration file
  if $::osfamily !~ /(Debian|Ubuntu)/ {
    file { '/etc/sysconfig/lsyncd':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/lsyncd-sysconfig.erb"),
      require => Package['lsyncd'],
      notify  => Service['lsyncd'],
    }

    # As of 2.1.4-3.el6 the rpm package doesn't include these directories
    # Later versions do, but we might need to change permissions
    file { [ '/var/log/lsyncd', '/var/run/lsyncd' ]:
      ensure  => 'directory',
      owner   => $logdir_owner,
      group   => $logdir_group,
      mode    => $logdir_mode,
      require => Package['lsyncd'],
      before  => Service['lsyncd'],
    }
  }
}
