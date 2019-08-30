#!/usr/bin/env bash

source /vagrant/utils/common-functions

install_ovs

hostname=$(hostname)

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/openvswitch/scripts/ovn-ctl start_ovsdb --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes
/usr/share/openvswitch/scripts/ovn-ctl start_northd
/usr/share/openvswitch/scripts/ovn-ctl start_controller

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=unix:/usr/var/run/openvswitch/ovnsb_db.sock
ovs-vsctl set open . external-ids:ovn-encap-ip=127.0.0.1
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
