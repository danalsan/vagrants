# OpenInfra Summit workshop - Devstack with OVN backend in Neutron

This directory contains vagrant file and shell scripts which can be used to
spawn 2 nodes devstack based topology with Neutron using OVN backend driver.

Such topology is used during the [OpenInfra Summit
workshop](https://www.openstack.org/summit/2020/summit-schedule/events/24548/troubleshooting-openstack-neutron-with-ml2ovn-backend-driver).

## Preparation of environment

To prepare this environment You need to have installed:

* [Vagrant](https://www.vagrantup.com/downloads)
* [Libvirt](https://libvirt.org/downloads.html)
* [Vagrant Libvirt Provider](https://github.com/vagrant-libvirt/vagrant-libvirt)

    $ vagrant plugin install vagrant-libvirt


## Installation

* Clone this repo:

```
$ git clone https://github.com/danalsan/vagrants.git
```

* Enter to the workshop directory:

```
$ cd vagrants/devstack-workshop
```

* Run vagrant:

```
$ vagrant up
```

* Once the configuration step is done you can SSH into the nodes and start
  playing with OVN:

```
$ vagrant status
$ vagrant ssh <target node>
$ sudo ovn-sbctl list Chassis
```

As a <target node> You can choose "central" or "worker1" in case of this
workshop.

### Troubleshooting

* Those vagrant files assumes that You have storage pool called "images" in
  libvirt. If You have pool with different name, please change in Vagrantfile
  line:

```
lb.storage_pool_name = 'images'
```


## Lab topology

This lab will spawn 2 VMs: "cental" and "worker1":

```
+------------------------+            +------------------------+
|central                 |            |worker1                 |
|                        | management |                        |
|eth1: 192.168.150.100/24+------------+eth1: 192.168.150.101/24|
|                        |            |                        |
|                        | dataplane  |                        |
|eth2: 172.24.4.10/24    +------------+eth2: 172.24.4.11/24    |
|                        |            |                        |
|                        |            |                        |
|                        |            |                        |
|                        |            |                        |
+------------------------+            +------------------------+
```

Node "central" is "all-in-one" type of node, with API services, like e.g.
Nova-api and neutron-server but also nova-compute and OVN agents.

Node "worker" is "compute" type of node, with nova-compute and OVN agent nodes
only.

There is also [Horizon](http://192.168.150.100/dashboard/) in this labj

## Virtual resources topology

Script used to provision this environment will automatically create some
networks, VMs and routers under "admin" project.

```
[vagrant@central ~]$ neutron net-list --project-id f5ba1307c87e41f5b7ab552556c4d3b2
neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
+--------------------------------------+--------+----------------------------------+-------------------------------------------------------+
| id                                   | name   | tenant_id                        | subnets                                               |
+--------------------------------------+--------+----------------------------------+-------------------------------------------------------+
| 071baed2-7d05-4843-bce5-3fd05eb22117 | shared | f5ba1307c87e41f5b7ab552556c4d3b2 | 159d3839-80fa-43d2-9b4a-8a9e80718182 192.168.233.0/24 |
| 28d94049-f4b4-4608-b905-a09db47d0af8 | blue   | f5ba1307c87e41f5b7ab552556c4d3b2 | 9e56d839-a615-4243-b838-77b47fc91733 20.0.0.0/24      |
| 95b3d6c9-6c75-4537-bf29-53eb8706d93e | red    | f5ba1307c87e41f5b7ab552556c4d3b2 | d27df6ec-7807-4f2a-b028-5dc4d6aa2c8b 10.0.0.0/24      |
| f9399e9c-a20e-41ac-85e6-e3d457fd069e | public | f5ba1307c87e41f5b7ab552556c4d3b2 | 24022f8a-88e6-40c1-83eb-f117989565f4 172.24.4.0/24    |
|                                      |        |                                  | 7cce40ca-c1ee-4074-8ca3-f4778d000da6 2001:db8::/64    |
+--------------------------------------+--------+----------------------------------+-------------------------------------------------------+
```

```
[vagrant@central ~]$ neutron router-list --project-id f5ba1307c87e41f5b7ab552556c4d3b2
neutron CLI is deprecated and will be removed in the future. Use openstack CLI instead.
+--------------------------------------+-----------+----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| id                                   | name      | tenant_id                        | external_gateway_info                                                                                                                                                                                                                                                          |
+--------------------------------------+-----------+----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| e83fd4f5-3902-44b2-90db-d0ab3b1a3b81 | router_rb | f5ba1307c87e41f5b7ab552556c4d3b2 | {"network_id": "f9399e9c-a20e-41ac-85e6-e3d457fd069e", "external_fixed_ips": [{"subnet_id": "24022f8a-88e6-40c1-83eb-f117989565f4", "ip_address": "172.24.4.115"}, {"subnet_id": "7cce40ca-c1ee-4074-8ca3-f4778d000da6", "ip_address": "2001:db8::3c2"}], "enable_snat": true} |
+--------------------------------------+-----------+----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

```
[vagrant@central ~]$ nova list --all-tenants --tenant f5ba1307c87e41f5b7ab552556c4d3b2
+--------------------------------------+--------+----------------------------------+--------+------------+-------------+-----------------------------+
| ID                                   | Name   | Tenant ID                        | Status | Task State | Power State | Networks                    |
+--------------------------------------+--------+----------------------------------+--------+------------+-------------+-----------------------------+
| 7e801970-675d-4789-a75a-02c3c6701a83 | blue-1 | f5ba1307c87e41f5b7ab552556c4d3b2 | ACTIVE | -          | Running     | blue=20.0.0.11, 172.24.4.131|
| b69a6adb-c5e2-4695-b5e8-c90a3afcd07d | blue-2 | f5ba1307c87e41f5b7ab552556c4d3b2 | ACTIVE | -          | Running     | blue=20.0.0.12              |
| 9a876ed7-8b7a-45a2-bb3c-0a806b3f5345 | red-1  | f5ba1307c87e41f5b7ab552556c4d3b2 | ACTIVE | -          | Running     | red=10.0.0.11, 172.24.4.130 |
| 591fd764-b8f2-4b0c-8dd4-aaf17c534578 | red-2  | f5ba1307c87e41f5b7ab552556c4d3b2 | ACTIVE | -          | Running     | red=10.0.0.12               |
+--------------------------------------+--------+----------------------------------+--------+------------+-------------+-----------------------------+

```

### Topology diagram

```
public       ++                   red        ++              blue       ++
172.24.4.0/24||                   10.0.0.0/24||              20.0.0.0/24||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||   +-----------------+   ||
             ||                              ||   |red-1            |   ||
             ||                              ||   |10.0.0.11        |   ||
             ||                              |----+FIP: 172.24.4.131|   ||
             ||                              ||   |                 |   ||
             ||                              ||   +-----------------+   ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||    +--------------------+    ||                         ||
             ||    |router_rb           |    ||                         ||     +-----------------+
             ||    |            20.0.0.1+--------------------------------|     |blue-1           |
             ||    |                    |    ||                         ||     |20.0.0.11        |
             |-----+172.24.4.115        |    ||                         |------+FIP: 172.24.4.132|
             ||    |                    |    ||                         ||     |                 |
             ||    |            10.0.0.1+-----|                         ||     +-----------------+
             ||    |                    |    ||                         ||
             ||    +--------------------+    ||   +-----------------+   ||
             ||                              ||   |red-2            |   ||
             ||                              ||   |10.0.0.12        |   ||
             ||                              |----+                 |   ||
             ||                              ||   |                 |   ||
             ||                              ||   +-----------------+   ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||     +-----------------+
             ||                              ||                         ||     |blue-2           |
             ||                              ||                         ||     |20.0.0.12        |
             ||                              ||                         |------+                 |
             ||                              ||                         ||     |                 |
             ||                              ||                         ||     +-----------------+
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ||                              ||                         ||
             ++                              ++                         ++
```
