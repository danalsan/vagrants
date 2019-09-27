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

ovn-nbctl lr-add router1
ovn-nbctl lrp-add router1 router1-net1 40:44:00:00:00:03 192.168.0.1/24
ovn-nbctl lsp-add network1 net1-router1
ovn-nbctl lsp-set-type net1-router1 router
ovn-nbctl lsp-set-addresses net1-router1 router
ovn-nbctl lsp-set-options net1-router1 router-port=router1-net1

ovn-nbctl lrp-add router1 router1-public 40:44:00:00:00:04 172.24.4.1/24
ovn-nbctl lsp-add public public-router1
ovn-nbctl lsp-set-type public-router1 router
ovn-nbctl lsp-set-addresses public-router1 router
ovn-nbctl lsp-set-options public-router1 router-port=router1-public

ovn-nbctl --id=@gc0 create Gateway_Chassis name=public-gw1 chassis_name=gw1 priority=20 -- --id=@gc1 create Gateway_Chassis name=public-gw2 chassis_name=gw2 priority=10 -- set Logical_Router_Port router1-public 'gateway_chassis=[@gc0,@gc1]'

ovn-nbctl lr-nat-add router1 snat 172.24.4.1 192.168.0.0/24
ovn-nbctl lr-nat-add router1 dnat_and_snat 172.24.4.100 192.168.0.11 vm1 40:44:00:00:00:05
ovn-nbctl lr-nat-add router1 dnat_and_snat 172.24.4.101 192.168.0.12 vm2 40:44:00:00:00:06
