#!/usr/bin/env bash

set -e

/usr/sbin/sshd -E /tmp/log -o 'LogLevel DEBUG'
knife zero diagnose

# Use Ipaddress
knife helper exec boot_ipaddress
knife node show zerohost
knife helper exec client_ipaddress

# Use Name
knife helper exec boot_name
knife node show 127.0.0.1
## Pending until merge https://github.com/chef/chef/pull/3195
# knife helper exec client_name
