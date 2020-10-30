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
ovs-vsctl set open . external-ids:ovn-bridge-mappings=segment1:br-ex

sleep 3

# Enable proxy-ARP and forwarding
ip l s dev br-ex up
ip a a 10.0.0.42/24 dev br-ex
sudo sysctl -w net.ipv4.conf.br-ex.proxy_arp=1
sudo sysctl -w net.ipv4.ip_forward=1

# Add fake VMs and static ECMP routes
case "$HOSTNAME" in
    worker1)
        ovn_add_phys_port vm1 40:44:00:00:00:01 10.0.0.10 24 10.0.0.1
        until [ "$(ovn-nbctl  --db=tcp:${central}:6641 get Logical_Switch_Port vm2 up)" == "true" ]; do echo 'Waiting for vm2 to boot' && sleep 2; done
        FLOW=$(ovn-sbctl --db="tcp:${central}:6642" --uuid lflow-list public | grep "40:44:00:00:00:02" | grep 10.0.0.20 | sed 's/.*uuid=\(0x[0-9a-f]*\),.*/\1/g')
        ip r a 10.0.0.20 nexthop via 100.65.1.2 nexthop via 100.64.1.2
        ;;
    worker2)
        ovn_add_phys_port vm2 40:44:00:00:00:02 10.0.0.20 24 10.0.0.1
        until [ "$(ovn-nbctl  --db=tcp:${central}:6641 get Logical_Switch_Port vm1 up)" == "true" ]; do echo 'Waiting for vm1 to boot' && sleep 2; done
        FLOW=$(ovn-sbctl --db="tcp:${central}:6642" --uuid lflow-list public | grep "40:44:00:00:00:01" | grep 10.0.0.10 | sed 's/.*uuid=\(0x[0-9a-f]*\),.*/\1/g')
        ip r a 10.0.0.10 nexthop via 100.65.2.2 nexthop via 100.64.2.2
        ;;
esac

sleep 3

# Remove the ARP responder flows
ovs-ofctl del-flows br-int cookie=$FLOW/-1
