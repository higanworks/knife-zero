#!/usr/bin/env bash

set -e

/usr/sbin/sshd -E /tmp/log -o 'LogLevel DEBUG'
knife zero diagnose

# Use Ipaddress
knife zero bootstrap 127.0.0.1 -N zerohost -x docker -P docker --sudo -V
knife node show zerohost
knife zero chef_client "name:zerohost" -a ipaddress -x docker -P docker --sudo -V

# Use Name
knife zero bootstrap 127.0.0.1 -N 127.0.0.1 -x docker -P docker --sudo -V
knife node show 127.0.0.1
## Pending until merge https://github.com/chef/chef/pull/3195
# knife zero chef_client "name:127.0.0.1" -a name -x docker -P docker --sudo -V
