#!/usr/bin/env bash

ovn-nbctl ls-add net_east
ovn-nbctl lsp-add net_east vm1
ovn-nbctl lsp-set-addresses vm1 "40:44:00:00:00:01 192.168.1.11"

ovn-nbctl ls-add public
ovn-nbctl lsp-add public public-localnet
ovn-nbctl lsp-set-type public-localnet localnet
ovn-nbctl lsp-set-addresses public-localnet unknown
ovn-nbctl lsp-set-options public-localnet network_name=external

ovn-nbctl lr-add router_east
ovn-nbctl lrp-add router_east router_east-net_east 40:44:00:00:00:04 192.168.1.1/24
ovn-nbctl lsp-add net_east net_east-router_east
ovn-nbctl lsp-set-type net_east-router_east router
ovn-nbctl lsp-set-addresses net_east-router_east router
ovn-nbctl lsp-set-options net_east-router_east router-port=router_east-net_east

#ovn-nbctl lrp-add router_east router_east-public 40:44:00:00:00:06 172.24.4.1/24
#ovn-nbctl lsp-add public public-router_east
#ovn-nbctl lsp-set-type public-router_east router
#ovn-nbctl lsp-set-addresses public-router_east router
#ovn-nbctl lsp-set-options public-router_east router-port=router_east-public

#ovn-nbctl --id=@gc0 create Gateway_Chassis name=public-gw_east chassis_name=gw_east priority=20 -- set Logical_Router_Port router_east-public 'gateway_chassis=[@gc0]'

#ovn-nbctl lr-nat-add router_east snat 172.24.4.1 192.168.1.0/24
#ovn-nbctl lr-nat-add router_east dnat_and_snat 172.24.4.111 192.168.1.11 vm1 40:44:00:00:00:07

# Interconnection bits

ovn-nbctl show | grep ts1
while [ $? -ne 0 ]; do
    sleep 3
    ovn-nbctl show | grep ts1
done

ovn-nbctl lrp-add router_east lrp-router_east-ts1 aa:aa:aa:aa:aa:01 169.254.100.1/24
ovn-nbctl lsp-add ts1 lsp-ts1-router_east -- lsp-set-addresses lsp-ts1-router_east -- lsp-set-type lsp-ts1-router_east router -- lsp-set-options lsp-ts1-router_east router-port=lrp-router_east-ts1
ovn-nbctl lrp-set-gateway-chassis lrp-router_east-ts1 gw_east 1
ovn-nbctl lr-route-add router_east 192.168.2.0/24 169.254.100.2
