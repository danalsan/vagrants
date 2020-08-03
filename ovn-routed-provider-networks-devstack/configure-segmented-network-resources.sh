#!/usr/bin/env bash
source ~/devstack/openrc admin demo
set -x

# Delete created by devstack flat public network
openstack router unset --external-gateway router1
openstack router show router1 -c interfaces_info -f yaml | grep port_id | awk {'print $2'} | xargs -I% openstack router remove port router1 %
openstack router delete router1
openstack network delete public

# Delete unused networks and security groups
openstack network delete shared
openstack network delete private
openstack security group list -c ID -f value  | xargs openstack security group delete

# Add new vlan mappings
iniset /etc/neutron/plugins/ml2/ml2_conf.ini  ml2_type_vlan network_vlan_ranges  segment-1:100:102,segment-2:200:202
sudo systemctl restart devstack@q-svc
sleep 10

# Based on: https://docs.openstack.org/neutron/pike/admin/config-routed-networks.html
openstack network create --share --provider-physical-network segment-1 --provider-network-type vlan --provider-segment 100 public
openstack network segment set --name segment-1 $(openstack network segment list --network public -c ID -f value)
openstack network segment create --physical-network segment-2 --network-type vlan --segment 200 --network public segment-2
openstack subnet create --network public --network-segment segment-1 --ip-version 4 --subnet-range 172.24.4.0/24 --allocation-pool start=172.24.4.100,end=172.24.4.200 public-segment-1-v4
openstack subnet create --network public --network-segment segment-2 --ip-version 4 --subnet-range 172.24.6.0/24 --allocation-pool start=172.24.6.100,end=172.24.6.200 public-segment-2-v4

# Create security group that accepts ICMP and TCP
sg_id=$(openstack security group create -c id -f value sg-for-multisegment)
openstack security group rule create --protocol icmp ${sg_id}
openstack security group rule create --protocol tcp ${sg_id}

# create port for VM1 in segment-1
openstack port create --security-group ${sg_id} --network public --fixed-ip subnet=$(openstack subnet list --name public-segment-1-v4 -c ID -f value),ip-address=172.24.4.110 vm1-segment-1

# create VM2 port in segment-2
openstack port create --security-group ${sg_id} --network public --fixed-ip subnet=$(openstack subnet list --name public-segment-2-v4 -c ID -f value),ip-address=172.24.6.110 vm2-segment-2

# create VM3 port in segment-1
openstack port create --security-group ${sg_id} --network public --fixed-ip subnet=$(openstack subnet list --name public-segment-1-v4 -c ID -f value),ip-address=172.24.4.120 vm3-segment-1

# create VM1 on worker1
openstack server create --flavor m1.tiny --nic port-id=$(openstack port list | grep vm1-segment-1 | awk {'print $2'}) --availability-zone nova:worker1 --image cirros-0.4.0-x86_64-disk vm1

# create VM2 on worker2
openstack server create --flavor m1.tiny --nic port-id=$(openstack port list | grep vm2-segment-2 | awk {'print $2'}) --availability-zone nova:worker2 --image cirros-0.4.0-x86_64-disk vm2

# create VM3 on worker3 (same segment as worker-1)
openstack server create --flavor m1.tiny --nic port-id=$(openstack port list | grep vm3-segment-1 | awk {'print $2'}) --availability-zone nova:worker3 --image cirros-0.4.0-x86_64-disk vm3
