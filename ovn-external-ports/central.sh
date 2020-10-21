#!/usr/bin/env bash

source /vagrant/utils/common-functions

centos_setup
install_ovn

hostname=$(hostname)

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/ovn/scripts/ovn-ctl start_ovsdb --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes
/usr/share/ovn/scripts/ovn-ctl start_northd

sleep 3

/vagrant/create_ovn_resources.sh
