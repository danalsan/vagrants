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

sleep 2

ovs-vsctl --may-exist add-br br-ex

ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings=external:br-ex,tenant:br-ex

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

sleep 3

# Add fake VMs
case "$HOSTNAME" in
    worker1)
        ovn_add_phys_port vm1 40:44:00:00:00:01 192.168.0.11 24 192.168.0.1
        ovs-vsctl set open . external-ids:ovn-chassis-mac-mappings="tenant:1e:02:ad:bb:aa:77"
        ;;
    worker2)
        ovn_add_phys_port vm2 40:44:00:00:00:02 192.168.0.12 24 192.168.0.1
        ovn_add_phys_port vm3 40:44:33:00:00:03 192.168.1.13 24 192.168.1.1
        ovs-vsctl set open . external-ids:ovn-chassis-mac-mappings="tenant:1e:02:ad:bb:aa:dd"
        ;;
esac
