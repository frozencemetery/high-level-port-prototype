#!/bin/sh -e

sudo sed -i '1i 127.0.0.1 test.box' /etc/hosts
sudo hostname test.box

if [ x"$KRB5_VER" == "x1.10" ]; then
    # no repositories
elif [ x"$KRB5_VER" == "x1.12" ]; then
    sudo apt-add-repository -y ppa:sssd/updates
elif [ x"$KRB5_VER" == "x1.13" ]; then
    sudo apt-add-repository -y ppa:sssd/updates
    sudo apt-add-repository -y ppa:rharwood/krb5-1.13
elif [ x"$KRB5_VER" == "xmaster" ]; then
    sudo apt-add-repository -y ppa:sssd/updates
    sudo apt-add-repository -y ppa:rharwood/krb5-master
else
    echo "I don't know what version that is!"
    exit 1
fi

sudo apt-get update -q
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y krb5-user krb5-kdc krb5-admin-server libkrb5-dev krb5-multidev
pip install --install-option='--no-cython-compile' cython
pip install -r test-requirements.txt
