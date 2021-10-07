#!/usr/bin/env bash

set -x

source /vagrant/utils/common-functions

install_devstack_ubuntu slave ovn ${worker} ${central}

sudo ovs-vsctl --may-exist add-br br-ex
sleep 3
sudo ovs-vsctl br-set-external-id br-ex bridge-id br-ex
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="public:br-ex"

# Add eth2 to br-ex
sudo ovs-vsctl add-port br-ex eth2
