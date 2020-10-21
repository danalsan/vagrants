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
ovs-vsctl set open . external-ids:ovn-cms-options="enable-chassis-as-gw"

# Add fake VMs
case "$HOSTNAME" in
    gw1)
        ovs-vsctl set open . external-ids:ovn-chassis-mac-mappings="tenant:1e:02:ad:bb:aa:44"
        ;;
    gw2)
       ovs-vsctl set open . external-ids:ovn-chassis-mac-mappings="tenant:1e:02:ad:bb:aa:cc"
       ;;
esac

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

