#!/usr/bin/env bash

source /vagrant/utils/common-functions

centos_setup
install_ovs

hostname=$(hostname)

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname

ovs-vsctl --may-exist add-br br-ex
ovs-vsctl br-set-external-id br-ex bridge-id br-ex

ovs-vsctl add-port br-ex eth1
ovs-vsctl add-port br-ex pext -- set Interface pext type=internal -- set Interface pext external_ids:iface-id=pext
ip netns add pext
ip link set pext netns pext
ip netns exec pext ip link add link pext name pext.170 type vlan id 170
ip netns exec pext ip link set pext.170 address 40:44:44:00:00:10
ip netns exec pext ip link set pext up
ip netns exec pext ip link set pext.170 up
#ip net e pext  dhclient -v -i pext.170 --no-pid
