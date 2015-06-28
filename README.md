# Puppet module: redis

## DEPRECATION NOTICE
This module is no more actively maintained and will hardly be updated.

Please find an alternative module from other authors or consider [Tiny Puppet](https://github.com/example42/puppet-tp) as replacement.

If you want to maintain this module, contact [Alessandro Franceschi](https://github.com/alvagante)


This is a Puppet redis module from the second generation of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-redis

Released under the terms of Apache 2 License.

This module requires functions provided by the Example42 Puppi module.

For detailed info about the logic and usage patterns of Example42 modules read README.usage on Example42 main modules set.

## USAGE - Basic management

* Install redis with default settings

        class { "redis": }

* Disable redis service.

        class { "redis":
          disable => true
        }

* Disable redis service at boot time, but don't stop if is running.

        class { "redis":
          disableboot => true
        }

* Remove redis package

        class { "redis":
          absent => true
        }

* Enable auditing without without making changes on existing redis configuration files

        class { "redis":
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { "redis":
          source => [ "puppet:///modules/lab42/redis/redis.conf-${hostname}" , "puppet:///modules/lab42/redis/redis.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { "redis":
          source_dir       => "puppet:///modules/lab42/redis/conf/",
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file 

        class { "redis":
          template => "example42/redis/redis.conf.erb",      
        }

* Define custom options that can be used in a custom template without the
  need to add parameters to the redis class

        class { "redis":
          template => "example42/redis/redis.conf.erb",    
          options  => {
            'LogLevel' => 'INFO',
            'UsePAM'   => 'yes',
          },
        }

* Automaticallly include a custom subclass

        class { "redis:"
          my_class => 'redis::example42',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)
  Note that this option requires the usage of Example42 puppi module

        class { "redis": 
          puppi    => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with
  a puppi::helper define ) to customize the output of puppi commands 

        class { "redis":
          puppi        => true,
          puppi_helper => "myhelper", 
        }

* Activate automatic monitoring (recommended, but disabled by default)
  This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { "redis":
          monitor      => true,
          monitor_tool => [ "nagios" , "monit" , "munin" ],
        }

* Activate automatic firewalling 
  This option requires the usage of Example42 firewall and relevant firewall tools modules

        class { "redis":       
          firewall      => true,
          firewall_tool => "iptables",
          firewall_src  => "10.42.0.0/24",
          firewall_dst  => "$ipaddress_eth0",
        }


[![Build Status](https://travis-ci.org/example42/puppet-redis.png?branch=master)](https://travis-ci.org/example42/puppet-redis)
