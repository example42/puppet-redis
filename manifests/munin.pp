
class redis::munin {

  include ::redis
  include ::munin

  munin::plugin { 'redis_':
    source => 'redis/munin.plugin.pl',
    linkplugins => true,
    content_config => template('redis/munin.conf.erb')
  }

  file { [
      "${::munin::config_dir}/plugins/redis_connected_clients",
      "${::munin::config_dir}/plugins/redis_connections",
      "${::munin::config_dir}/plugins/redis_requests",
      "${::munin::config_dir}/plugins/redis_used_memory",
      "${::munin::config_dir}/plugins/redis_used_keys",
      "${::munin::config_dir}/plugins/redis_hit_rate",
      "${::munin::config_dir}/plugins/redis_evicted_keys"
    ]:
    ensure  => link,
    target  => "${::munin::plugins_dir}/redis_",
    require => [
      File["${::munin::plugins_dir}/redis_"],
      Package['munin']
    ]
  }

}
