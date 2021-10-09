#!/usr/bin/env bash

set -x

source /vagrant/utils/common-functions

install_devstack_ubuntu slave ovs ${worker} ${central}
