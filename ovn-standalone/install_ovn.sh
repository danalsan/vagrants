source /vagrant/utils/common-functions

install_ovs

sudo /usr/share/openvswitch/scripts/ovs-ctl start --system-id="ovn"
sudo /usr/share/openvswitch/scripts/ovn-ctl start_ovsdb --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes
sudo /usr/share/openvswitch/scripts/ovn-ctl start_northd
sudo /usr/share/openvswitch/scripts/ovn-ctl start_controller
sudo ovs-vsctl set open . external-ids:ovn-remote=unix:/usr/var/run/openvswitch/ovnsb_db.sock
sudo ovs-vsctl set open . external-ids:ovn-encap-ip=127.0.0.1
sudo ovs-vsctl set open . external-ids:ovn-encap-type=geneve
