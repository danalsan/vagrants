#!/usr/bin/env bash
set -x

# Change the ovn remote protocol from tcp to ssl
sudo ovs-vsctl set open . external_ids:ovn-remote=$(ovs-vsctl get open . external_ids:ovn-remote | sed -e 's/tcp/ssl/g')
