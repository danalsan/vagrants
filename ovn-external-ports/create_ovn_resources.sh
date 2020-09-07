#!/usr/bin/env bash

ovn-nbctl ls-add network1
ovn-nbctl lsp-add network1 vm1
ovn-nbctl lsp-set-addresses vm1 "40:44:00:00:00:01 192.168.0.11"
ovn-nbctl lsp-add network1 vm2
ovn-nbctl lsp-set-addresses vm2 "40:44:00:00:00:02 192.168.0.12"

ovn-nbctl ls-add public
ovn-nbctl lsp-add public public-localnet
ovn-nbctl lsp-set-type public-localnet localnet
ovn-nbctl lsp-set-addresses public-localnet unknown
ovn-nbctl lsp-set-options public-localnet network_name=external

ovn-nbctl ls-add network2
ovn-nbctl lsp-add network2 vm3
ovn-nbctl lsp-set-addresses vm3 "40:44:33:00:00:03 192.168.1.13"

ovn-nbctl lsp-add network2 net2-localnet
ovn-nbctl lsp-set-type net2-localnet  localnet
ovn-nbctl lsp-set-addresses net2-localnet unknown
ovn-nbctl lsp-set-options net2-localnet network_name=tenant
ovn-nbctl set Logical_Switch_Port net2-localnet tag=170

ovn-nbctl lsp-add network1 net1-localnet
ovn-nbctl lsp-set-type net1-localnet  localnet
ovn-nbctl lsp-set-addresses net1-localnet unknown
ovn-nbctl lsp-set-options net1-localnet network_name=tenant
ovn-nbctl set Logical_Switch_Port net1-localnet tag=190

ovn-nbctl lr-add router1
ovn-nbctl lrp-add router1 router1-net1 40:44:00:00:00:03 192.168.0.1/24
ovn-nbctl lsp-add network1 net1-router1
ovn-nbctl lsp-set-type net1-router1 router
ovn-nbctl lsp-set-addresses net1-router1 router
ovn-nbctl lsp-set-options net1-router1 router-port=router1-net1

ovn-nbctl lrp-add router1 router1-public 40:44:00:00:00:04 172.24.14.1/24
ovn-nbctl lsp-add public public-router1
ovn-nbctl lsp-set-type public-router1 router
ovn-nbctl lsp-set-addresses public-router1 router
ovn-nbctl lsp-set-options public-router1 router-port=router1-public


ovn-nbctl lrp-add router1 router1-net2 40:44:33:00:00:05 192.168.1.1/24
ovn-nbctl lsp-add network2 net2-router1
ovn-nbctl lsp-set-type net2-router1 router
ovn-nbctl lsp-set-addresses net2-router1 router
ovn-nbctl lsp-set-options net2-router1 router-port=router1-net2


ovn-nbctl --id=@gc0 create Gateway_Chassis name=public-gw1 chassis_name=gw1 priority=20 -- --id=@gc1 create Gateway_Chassis name=public-gw2 chassis_name=gw2 priority=10 -- set Logical_Router_Port router1-public 'gateway_chassis=[@gc0,@gc1]'

ovn-nbctl lr-nat-add router1 snat 172.24.14.1 192.168.0.0/24
ovn-nbctl lr-nat-add router1 snat 172.24.14.1 192.168.1.0/24
ovn-nbctl lr-nat-add router1 dnat_and_snat 172.24.14.100 192.168.0.11 vm1 40:44:00:00:00:05
ovn-nbctl lr-nat-add router1 dnat_and_snat 172.24.14.101 192.168.0.12 vm2 40:44:00:00:00:06

# Create the external port
ovn-nbctl lsp-add network2 pext
ovn-nbctl lsp-set-addresses pext "40:44:44:00:00:10 192.168.1.111"
ovn-nbctl lsp-set-type pext external

# Schedule the external port in gw2
ovn-nbctl --id=@ha_chassis  create HA_Chassis chassis_name=gw2 priority=1 -- --id=@ha_chassis_group create HA_Chassis_Group name=default2 ha_chassis=[@ha_chassis] -- set Logical_Switch_Port pext ha_chassis_group=@ha_chassis_group

# Add DHCP options for the external port
ovn-nbctl --id=@dhcp create dhcp_options cidr=192.168.1.0/24 options='"lease_time"="3600" "router"="192.168.1.1" "server_id"="192.168.1.1" "server_mac"="40:44:44:00:aa:ee"' -- set Logical_Switch_port pext dhcpv4_options=[@dhcp]
