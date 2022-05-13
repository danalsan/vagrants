#!/usr/bin/env bash

source /vagrant/utils/common-functions

centos_setup
install_ovn

hostname=$(hostname)
ip=${!hostname}

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/ovn/scripts/ovn-ctl start_controller

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:${central}:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$ip

ovs-vsctl --may-exist add-br br-ex
ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings=external:br-ex

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

sleep 3

# Add fake VMs and containers
case "$HOSTNAME" in
    worker1)
        ovn_add_phys_port vm1 40:44:00:00:00:01 192.168.0.11 24 192.168.0.1
        add_vlan_device vm1 child1 40:44:00:00:00:03 192.168.1.13 24 30
        ;;
    worker2)
        ovn_add_phys_port vm2 40:44:00:00:00:02 192.168.0.12 24 192.168.0.1
        add_vlan_device vm2 child2 40:44:00:00:00:04 192.168.1.14 24 50
        ;;
esac
