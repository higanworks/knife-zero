#!/usr/bin/env bash

set -xe

/usr/sbin/sshd -E /tmp/log -o 'LogLevel DEBUG'
knife zero diagnose

# Use Ipaddress
knife helper exec boot_ipaddress --print
knife helper exec boot_ipaddress
knife node show zerohost
knife helper exec client_ipaddress
knife helper exec client_ipaddress --print

# Use Name
knife helper exec boot_name --print
knife helper exec boot_name
knife node show 127.0.0.1
## Pending until merge https://github.com/chef/chef/pull/3195
# knife helper exec client_name
