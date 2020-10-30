#!/usr/bin/env bash

source /vagrant/utils/common-functions

centos_setup
install_ovn

hostname=$(hostname)

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/ovn/scripts/ovn-ctl start_ovsdb --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes
/usr/share/ovn/scripts/ovn-ctl start_northd
/usr/share/ovn/scripts/ovn-ctl start_controller

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=unix:/var/run/ovn/ovnsb_db.sock
ovs-vsctl set open . external-ids:ovn-encap-ip=127.0.0.1
ovs-vsctl set open . external-ids:ovn-encap-type=geneve

sleep 3


ovn-nbctl ls-add public
ovn-nbctl lsp-add public public-segment1
ovn-nbctl lsp-set-type public-segment1 localnet
ovn-nbctl lsp-set-addresses public-segment1 unknown
ovn-nbctl lsp-set-options public-segment1 network_name=segment1
ovn-nbctl lsp-add public vm1
ovn-nbctl lsp-add public vm2
ovn-nbctl lsp-set-addresses vm1 "40:44:00:00:00:01 10.0.0.10"
ovn-nbctl lsp-set-addresses vm2 "40:44:00:00:00:02 10.0.0.20"

# Enable forwarding and disable reverse path filter
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.ip_forward=1

# Add static ECMP routes to the VMs
ip r a 10.0.0.10 nexthop via 100.64.1.3 nexthop via 100.65.1.3
ip r a 10.0.0.20 nexthop via 100.64.2.3 nexthop via 100.65.2.3
