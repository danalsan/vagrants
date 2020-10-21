#!/usr/bin/env bash
set -x

# Force traffic to 172.24.4.132 FIP to be centralized via Geneve tunnel
ovn-nbctl clear NAT $(ovn-nbctl --bare --columns _uuid find NAT external_ip=172.24.4.132) external_mac
