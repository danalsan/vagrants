#!/usr/bin/env bash

source /vagrant/utils/common-functions

centos_setup
install_ovn

hostname=$(hostname | sed -e 's/-/_/g')
ip=$(printenv $hostname)

printenv gw_east

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/ovn/scripts/ovn-ctl start_controller

ovs-vsctl show | grep br-int
while [ $? -ne 0 ]; do
    sleep 2
    ovs-vsctl show | grep br-int
done

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:${1}:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$ip

ovs-vsctl --may-exist add-br br-ex
ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings=external:br-ex
ovs-vsctl set open . external-ids:ovn-cms-options="enable-chassis-as-gw"

ovs-vsctl set open_vswitch . external_ids:ovn-is-interconn=true

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2
