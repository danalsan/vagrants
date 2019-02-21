sudo setenforce 0

sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

sudo yum group install "Development Tools" -y
sudo yum install python-devel python-six -y

GIT_REPO=${GIT_REPO:-https://github.com/openvswitch/ovs}
GIT_BRANCH=${GIT_BRANCH:-master}

git clone $GIT_REPO
cd ovs


if [[ "z$GIT_BRANCH" != "z" ]]; then
    git checkout $GIT_BRANCH
fi

./boot.sh
CFLAGS="-O0 -g" ./configure --prefix=/usr
make -j5 V=0 install
sudo make install

hostname=$(hostname)
ip=${!hostname}

sudo /usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
sudo /usr/share/openvswitch/scripts/ovn-ctl start_controller

sudo ovs-vsctl set open . external-ids:ovn-bridge=br-int
sudo ovs-vsctl set open . external-ids:ovn-remote=tcp:192.168.50.10:6642
sudo ovs-vsctl set open . external-ids:ovn-encap-type=geneve
sudo ovs-vsctl set open . external-ids:ovn-encap-ip=$ip
