#!/usr/bin/env bash
set -x

# Posion the MAC_Binding entry for the devstack IP in the FIP network
for i in $(ovn-sbctl --bare --columns _uuid find mac_binding ip="172.24.4.3"); do ovn-sbctl set MAC_Binding $i mac="de\:ad\:be\:ef\:01\:01"; done
