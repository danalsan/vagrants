#!/usr/bin/env bash
set -x

source /vagrant/utils/common-functions

hostname=$(hostname)

# install vim
sudo yum install -y vim

install_devstack master

sudo ovs-vsctl --may-exist add-br br-ex
sleep 3
sudo ovs-vsctl br-set-external-id br-ex bridge-id br-ex
sudo ovs-vsctl br-set-external-id br-int bridge-id br-int
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="public:br-ex"
sudo ovs-vsctl set open . external-ids:ovn-cms-options="enable-chassis-as-gw"

# Add eth2 to br-ex
sudo ovs-vsctl add-port br-ex eth2
sudo ip link set br-ex up
sudo ip route add 172.24.4.0/24 dev br-ex
sudo ip addr add 172.24.4.3/24 dev br-ex

# Enable DVR (unfortunately there's not support yet in Devstack)
sed -i '/ovn_nb_connection.*/a enable_distributed_floating_ip=True' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo systemctl restart devstack@q-svc
sleep 10

source ~/devstack/openrc admin admin

openstack security group create test
openstack security group rule create --ingress --protocol tcp --dst-port 22 test
openstack security group rule create --ingress --protocol icmp test
openstack security group rule create --egress test

openstack network create red
openstack network create blue

openstack subnet create --network red red --subnet-range 10.0.0.0/24
openstack subnet create --network blue blue --subnet-range 20.0.0.0/24

openstack router create router_rb
openstack router set router_rb --external-gateway public --fixed-ip ip-address=172.24.4.115
openstack router add subnet router_rb red
openstack router add subnet router_rb blue


IMAGE_ID=$(openstack image list -c ID -c Name -f value  | grep cirros | head -n1 |  awk {'print $1'})
RED_NET=$(openstack network show red -c id -f value)
BLUE_NET=$(openstack network show blue -c id -f value)


for n in $(seq 1 2); do
 echo creating server red-$n
 port_red=$(openstack port create --network $RED_NET --fixed-ip ip-address=10.0.0.1$n --security-group test port-red-$n -c id -f value)
 openstack server create --flavor m1.tiny --image $IMAGE_ID --nic port-id=$port_red red-$n

 echo creating server blue-$n
 port_blue=$(openstack port create --network $BLUE_NET --fixed-ip ip-address=20.0.0.1$n --security-group test port-blue-$n -c id -f value)
 openstack server create --flavor m1.tiny --image $IMAGE_ID --nic port-id=$port_blue blue-$n

 echo creating FIP 172.24.4.13$n
 openstack floating ip create --floating-ip-address 172.24.4.13$n public
done

openstack server add floating ip red-1 172.24.4.131
openstack server add floating ip blue-1 172.24.4.132
