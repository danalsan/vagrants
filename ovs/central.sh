#!/usr/bin/env bash
set -x

source /vagrant/utils/common-functions

hostname=$(hostname)

install_devstack_ubuntu master ovs ${central}
