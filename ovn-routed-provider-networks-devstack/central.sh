#!/usr/bin/env bash
set -x

source /vagrant/utils/common-functions

hostname=$(hostname)

install_devstack master

# We don't want to configure this node as external gateway
sudo ovs-vsctl remove Open_vSwitch . external_ids ovn-bridge-mappings
sudo ovs-vsctl remove Open_vSwitch . external_ids ovn-cms-options
