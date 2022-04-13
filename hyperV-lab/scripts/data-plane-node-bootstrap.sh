#! /bin/bash

#/bin/bash /vagrant/scripts/join.sh -v

sudo -i -u vagrant bash << EOF
whoami
EOF

nowdate=$(date --utc +%FT%TZ)

echo $nowdate
echo "Manually attach node to cluster.."