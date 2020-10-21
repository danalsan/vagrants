#!/usr/bin/env bash
set -x

# Clear the DHCP options for the blue-1 VM
ovn-nbctl clear Logical_Switch_Port $(ovn-nbctl --bare --columns _uuid find Logical_Switch_Port external_ids:"neutron\:port_name"=port-blue-1) dhcpv4_options
