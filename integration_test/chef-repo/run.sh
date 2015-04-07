#!/usr/bin/env bash

set -e

/usr/sbin/sshd -E /tmp/log -o 'LogLevel DEBUG'
knife zero diagnose
knife zero bootstrap 127.0.0.1 -N zerohost -x docker -P docker --sudo -V
knife node show zerohost
knife zero chef_client "name:zerohost" -a ipaddress -x docker -P docker --sudo -V

