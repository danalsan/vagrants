#!/usr/bin/env bash

ovn-nbctl ls-add net_west
ovn-nbctl lsp-add net_west vm2
ovn-nbctl lsp-set-addresses vm2 "40:44:00:00:00:02 192.168.2.12"

ovn-nbctl ls-add public
ovn-nbctl lsp-add public public-localnet
ovn-nbctl lsp-set-type public-localnet localnet
ovn-nbctl lsp-set-addresses public-localnet unknown
ovn-nbctl lsp-set-options public-localnet network_name=external

ovn-nbctl lr-add router_west
ovn-nbctl lrp-add router_west router_west-net_west 40:44:00:00:00:10 192.168.2.1/24
ovn-nbctl lsp-add net_west net_west-router_west
ovn-nbctl lsp-set-type net_west-router_west router
ovn-nbctl lsp-set-addresses net_west-router_west router
ovn-nbctl lsp-set-options net_west-router_west router-port=router_west-net_west

#ovn-nbctl lrp-add router_west router_west-public 40:44:00:00:00:11 172.24.4.2/24
#ovn-nbctl lsp-add public public-router_west
#ovn-nbctl lsp-set-type public-router_west router
#ovn-nbctl lsp-set-addresses public-router_west router
#ovn-nbctl lsp-set-options public-router_west router-port=router_west-public

#ovn-nbctl --id=@gc0 create Gateway_Chassis name=public-gw_west chassis_name=gw_west priority=20 -- set Logical_Router_Port router_west-public 'gateway_chassis=[@gc0]'

#ovn-nbctl lr-nat-add router_west snat 172.24.4.2 192.168.2.0/24
#ovn-nbctl lr-nat-add router_west dnat_and_snat 172.24.4.112 192.168.2.12 vm2 40:44:00:00:00:12

# Interconnection bits

ovn-nbctl show | grep ts1
while [ $? -ne 0 ]; do
    sleep 3
    ovn-nbctl show | grep ts1
done

ovn-nbctl lrp-add router_west lrp-router_west-ts1 aa:aa:aa:aa:aa:02 169.254.100.2/24
ovn-nbctl lsp-add ts1 lsp-ts1-router_west -- lsp-set-addresses lsp-ts1-router_west -- lsp-set-type lsp-ts1-router_west router -- lsp-set-options lsp-ts1-router_west router-port=lrp-router_west-ts1
ovn-nbctl lrp-set-gateway-chassis lrp-router_west-ts1 gw_west 1
ovn-nbctl lr-route-add router_west 192.168.1.0/24 169.254.100.1
