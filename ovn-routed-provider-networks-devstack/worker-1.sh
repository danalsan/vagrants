#!/usr/bin/env bash

set -x

source /vagrant/utils/common-functions

install_devstack slave ${central}

ovs-vsctl --may-exist add-br br-ex
sleep 60
ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings="segment-1:br-ex"
ovs-vsctl set open . external-ids:ovn-cms-options="enable-chassis-as-gw"

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2
