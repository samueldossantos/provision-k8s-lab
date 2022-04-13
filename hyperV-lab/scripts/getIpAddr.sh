#! /bin/bash

ip -o route get to 8.8.8.8 |            \
 sed -n 's/.*src \([0-9.]\+\).*/\1/p' | \
 tee /vagrant/scripts/apiServerIp.log