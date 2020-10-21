#!/usr/bin/env bash


source /vagrant/utils/common-functions

centos_setup
install_ovn

hostname=$(hostname)


if [ $hostname == "central-ic" ]
then
    /usr/share/ovn/scripts/ovn-ctl --db-ic-nb-create-insecure-remote=yes  --db-ic-sb-create-insecure-remote=yes start_ic_ovsdb
    ovn-ic-nbctl ts-add ts1
    exit 0
fi

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/ovn/scripts/ovn-ctl start_ovsdb --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes
/usr/share/ovn/scripts/ovn-ctl start_northd
/usr/share/ovn/scripts/ovn-ctl start_controller

/usr/share/ovn/scripts/ovn-ctl --ovn-ic-nb-db=tcp:${central_ic}:6645 --ovn-ic-sb-db=tcp:${central_ic}:6646 --ovn-northd-nb-db=unix:/usr/var/run/ovn/ovnnb_db.sock --ovn-northd-sb-db=unix:/usr/var/run/ovn/ovnsb_db.sock start_ic

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=unix:/var/run/ovn/ovnsb_db.sock
ovs-vsctl set open . external-ids:ovn-encap-ip=127.0.0.1
ovs-vsctl set open . external-ids:ovn-encap-type=geneve

sleep 3

case "$HOSTNAME" in
    central-east)
        ovn-nbctl set NB_Global . name=east
        /vagrant/create_ovn_resources_east.sh
        ;;
    central-west)
        ovn-nbctl set NB_Global . name=west
        /vagrant/create_ovn_resources_west.sh
        ;;
esac
