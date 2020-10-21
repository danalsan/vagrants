#!/usr/bin/env bash

set -x

source /vagrant/utils/common-functions

# install vim
sudo yum install -y vim

install_devstack slave ${central}

sudo yum remove -y iptables-services

sudo ovs-vsctl --may-exist add-br br-ex
sleep 3
sudo ovs-vsctl br-set-external-id br-ex bridge-id br-ex
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="public:br-ex"

# Add eth2 to br-ex
sudo ovs-vsctl add-port br-ex eth2
