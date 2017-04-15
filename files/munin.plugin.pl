#!/usr/bin/perl -w

#
# File managed by Puppet
#

#
## Copyright (C) 2011 Colin Mollenhour <http://colin.mollenhour.com/>
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; version 2 dated June,
## 1991.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
##
## Based on v3 plugin from munin exchange
## Copyright (C) 2009 Gleb Voronich <http://stanly.net.ua/>
##
## Installation process:
##
## 1. Download the plugin to your plugins directory (e.g. /usr/share/munin/plugins)
## 2. Create a symlink using either individual graph names or use the wildcard name: redis_
## 3. Edit plugin-conf.d/munin-node if it is needed:
##      env.host and env.port     (if using tcp, default is 127.0.0.1:6379)
##      env.path                  (if using sockets)
##      env.password              (for password protected Redis server)
## 4. Restart munin-node service

#%# family=auto
#%# capabilities=autoconf suggest

use strict;
use Switch;

sub get_stats {

    use IO::Socket;

    # Establish either a unix socket or tcp connection
    my $class;
    my %options;
    if( exists $ENV{'path'} ) {
        $class = "IO::Socket::UNIX";
        %options = (
            Peer => $ENV{'path'}
        );
    }
    else {
        my $HOST = exists $ENV{'host'} ? $ENV{'host'} : "127.0.0.1";
        my $PORT = exists $ENV{'port'} ? $ENV{'port'} : 6379;
        my $server = "$HOST:$PORT";
        $class = "IO::Socket::INET";
        %options = (
            PeerAddr => $server,
            Proto => 'tcp'
        );
    }
    my $sock = $class->new(%options) || die "no (Could not connect to redis: $!)";

    # Password authentication
    if ( exists $ENV{'password'} ) {
        print $sock "AUTH ", $ENV{'password'}, "\r\n";
        my $result = <$sock> || die "no (Can't read redis socket: $!)";
    }

    # Get redis info (2.4+)
    print $sock "INFO\r\n";
    my $result = <$sock> || die "no (Can't read redis socket: $!)";
    my $rep;
    read($sock, $rep, substr($result,1)) || die "no (Can't read redis socket: $!)";
    my $hash;
    foreach (split(/\r\n/, $rep)) {
        my ($key,$val) = split(/:/, $_, 2);
        $hash->{$key} = $val;
    }
    close ($sock);
    return $hash;
}

# Support wildcard plugin: http://munin-monitoring.org/wiki/WildcardPlugins
if ( defined $ARGV[0] and $ARGV[0] eq "suggest" ) {
    print "connected_clients\n";
    print "connections\n";
    print "requests\n";
    print "used_memory\n";
    print "used_keys\n";
    print "hit_rate\n";
    print "evicted_keys\n";
    exit 0;
}

# Support autoconf
if ( defined $ARGV[0] and $ARGV[0] eq "autoconf" ) {
    get_stats();
    print "yes\n";
}

# Run individual plugins
my $config = ( defined $ARGV[0] and $ARGV[0] eq "config" );
my $category = exists $ENV{'category'} ? $ENV{'category'} : 'redis';
$0 =~ s/(.*)redis(24)?_//g;
switch ($0) {

    case "connected_clients" {
        if ( $config ) {
            print "graph_title Connected clients\n";
            print "graph_vlabel Connected clients\n";
            print "connected_clients.label Connected clients\n";
            print "graph_category $category\n";
            exit 0;
        }

        my $hash = &get_stats();
        print "connected_clients.value " . $hash->{'connected_clients'} . "\n";
    }

    case "connections" {
        if ( $config ) {
            print "graph_title Connections\n";
            print "graph_vlabel Connections per \${graph_period}\n";
            print "graph_category $category\n";
            print "connections.label Connections\n";
            print "connections.type COUNTER\n";
            exit 0;
        }

        my $hash = &get_stats();
        print "connections.value ". $hash->{'total_connections_received'} ."\n";
    }

    case "requests" {
        if ( $config ) {
            print "graph_title Requests\n";
            print "graph_vlabel Requests per \${graph_period}\n";
            print "graph_category $category\n";
            print "requests.label Requests\n";
            print "requests.type COUNTER\n";
            exit 0;
        }

        my $hash = &get_stats();
        print "requests.value ". $hash->{'total_commands_processed'} ."\n";
    }

    case "used_memory" {
        if ( $config ) {
            print "graph_title Used memory\n";
            print "graph_vlabel Used memory\n";
            print "graph_category $category\n";
            print "graph_args --base 1024 -l 0\n";
            print "used_memory.label Used memory\n";
            print "used_memory_rss.label Used memory (RSS)\n";
            print "used_memory_peak.label Peak used memory\n";
            exit 0;
        }

        my $hash = &get_stats();
        print "used_memory.value ". $hash->{'used_memory'}  ."\n";
        print "used_memory_rss.value ". $hash->{'used_memory_rss'}  ."\n";
        print "used_memory_peak.value ". $hash->{'used_memory_peak'}  ."\n";
    }
    
    case "used_keys" {
        my $hash = &get_stats();
        my $dbs;
        foreach my $key (keys %{$hash}) {
            if ( $key =~ /^db\d+$/ && $hash->{$key} =~ /keys=(\d+),expires=(\d+)/ ) {
                $dbs->{$key} = [ $1, $2 ];
            }
        }

        if ( $config ) {
            print "graph_title Used / Expiring Keys\n";
            print "graph_vlabel Keys\n";
            print "graph_category $category\n";

            foreach my $db (keys %{$dbs}) {
                printf "%s_keys.label %s keys\n", $db, $db;
                printf "%s_expires.label %s expires\n", $db, $db;
            }

            exit 0;
        }

        foreach my $db (keys %{$dbs}) {
            printf "%s_keys.value %d\n", $db, $dbs->{$db}[0];
            printf "%s_expires.value %d\n", $db, $dbs->{$db}[1];
        }
    }

    case "hit_rate" {
        if ( $config ) {
            print "graph_title Keyspace Hit Rate\n";
            print "graph_args --base 1000 --upper-limit 100 --lower-limit 0 --rigid\n";
            print "graph_vlabel % of requests\n";
            print "graph_category $category\n";
            print "graph_scale no\n";
            print "graph_order misses hits\n";
            print "misses.label misses\n";
            print "misses.min 0\n";
            print "misses.graph off\n";
            print "misses.type DERIVE\n";
            print "hits.label hits\n";
            print "hits.min 0\n";
            print "hits.type DERIVE\n";
            print "hits.draw AREA\n";
            print "hits.cdef 0,hits,+,hits,misses,+,/,100,*\n";
            exit 0;
        }

        my $hash = &get_stats();
        print "misses.value " . $hash->{'keyspace_misses'} . "\n";
        print "hits.value ". $hash->{'keyspace_hits'} . "\n";
    }

    case "evicted_keys" {
        if ( $config ) {
            print "graph_title Evicted Keys\n";
            print "graph_vlabel Evicted Keys per \${graph_period}\n";
            print "graph_category $category\n";
            print "graph_args --base 1000 -l 0\n";
            print "evicted.label evicted keys\n";
            print "evicted.type DERIVE\n";
            print "evicted.min 0\n";
            exit 0;
        }

        my $hash = &get_stats();
        print "evicted.value ". $hash->{'evicted_keys'}  ."\n";
    }
      
}

# vim: ft=perl ai ts=4 sw=4 et: