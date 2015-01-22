#!/bin/bash

pushd ~
git clone https://github.com/krb5/krb5
pushd krb5/src
autoreconf -f -i
./configure --prefix=/usr/local
make
sudo make install
popd
popd
export PATH=/usr/local/sbin:/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/opt/krb5/lib:$LD_LIBRARY_PATH
export GSSAPI_MAIN_LIB=/usr/local/lib/libgssapi_krb5.so

flake8 setup.py
F8_SETUP=$?

flake8 gssapi
F8_PY=$?

flake8 gssapi --filename='*.pyx,*.pxd' --ignore=E225,E226,E227,E901
F8_MAIN_CYTHON=$?

python setup.py nosetests
TEST_RES=$?

if [ $F8_SETUP -eq 0 -a $F8_PY -eq 0 -a $F8_MAIN_CYTHON -eq 0 -a $TEST_RES -eq 0 ]; then
    exit 0
else
    exit 1
fi
