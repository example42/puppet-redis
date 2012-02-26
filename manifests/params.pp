# Class: redis::params
#
# This class defines default parameters used by the main module class redis
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to redis class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class redis::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'redis-server',
    default => 'redis',
  }

  $service = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => 'redis-server',
    default => 'redis',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'redis-server',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    default => 'redis',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/redis',
  }

  $config_file = $::operatingsystem ? {
    /(?i:RedHat|Scientific|Centos|Fedora)/ => '/etc/redis.conf',
    default => '/etc/redis/redis.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    default                   => '',
  }

  $pid_file = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/var/run/redis.pid',
    default => '/var/run/redis/redis.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/redis',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/redis',
  }

  $log_file = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/var/log/redis/redis-server.log',
    default => '/var/log/redis/redis.log',
  }

  $port = '6379'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = ''
  $template = ''
  $options = ''
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false

}
