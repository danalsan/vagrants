#!/usr/bin/env bash
set -x

# Configure the wrong bridge mappings
sudo ovs-vsctl set open . external_ids:ovn-bridge-mappings="datacentre:br-ex"
