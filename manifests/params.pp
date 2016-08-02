class lsyncd::params {
  case $::osfamily {
    'Debian': {
      $config_path = '/etc/lsyncd'
      $config_file = "${config_path}/lsyncd.conf.lua"
    }

    default: {
      $config_path = '/etc'
      $config_file = "${config_path}/lsyncd.conf"
    }
  }
}
