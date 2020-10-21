#!/usr/bin/env bash

source /vagrant/utils/common-functions

centos_setup
install_ovn

hostname=$(hostname | sed -e 's/-/_/g')
ip=$(printenv $hostname)

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

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

sleep 3

# Add fake VMs
case "$hostname" in
    worker_east)
        ovn_add_phys_port vm1 40:44:00:00:00:01 192.168.1.11 24 192.168.1.1
        ;;
    worker_west)
        ovn_add_phys_port vm2 40:44:00:00:00:02 192.168.2.12 24 192.168.2.1
        ;;
esac
