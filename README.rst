OVN Vagrants
============

This repository contains a list of vagrant files that can be used to
set up OVN in many different topologies.

How to
------

#. Install the vagrant

#. Install the ``vagrant-libvirt`` extension::

    $ vagrant plugin install vagrant-libvirt

#. Choose the topology and start Vagrant (e.g ovn-multinode)::

    $ cd ovn-multinode
    $ vagrant up

#. Once the configuration step is done you can SSH into the nodes and
   start playing with OVN::

    $ vagrant status
    $ vagrant ssh <target node>
    $ sudo ovn-sbctl list Chassis
