source /vagrant/utils/common-functions

install_ovs

hostname=$(hostname)
ip=${!hostname}

sudo /usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
sudo /usr/share/openvswitch/scripts/ovn-ctl start_controller

sudo ovs-vsctl set open . external-ids:ovn-bridge=br-int
sudo ovs-vsctl set open . external-ids:ovn-remote=tcp:192.168.50.10:6642
sudo ovs-vsctl set open . external-ids:ovn-encap-type=geneve
sudo ovs-vsctl set open . external-ids:ovn-encap-ip=$ip

ovs-vsctl --may-exist add-br br-ex
ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings=external:br-ex

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

