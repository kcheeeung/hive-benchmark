#!/bin/bash

# Connects the headnode to worker nodes without needing password to ssh
if [[ "$#" -ne 1 ]]; then
    echo "Provide a password to your cluster"
    exit 1
fi

PASSWORD=$1

sudo apt-get -y -qq install sshpass
sudo apt-get -y -qq install pdsh

# Here we check if a keypair already exists in the default location. If not, we create one.
if [[ ! -e ~/.ssh/id_rsa ]]; then
    echo "Generating keys\n"
    ssh-keygen -f ~/.ssh/id_rsa -P ""
fi

for slave in `cat /etc/hadoop/conf/slaves`; do
    # echo "ssh-copy-id on $slave"
    sshpass -p $PASSWORD ssh-copy-id -o StrictHostKeyChecking=no $slave
done

pdsh -R ssh -w ^/etc/hadoop/conf/slaves sudo apt-get -y -qq install linux-tools-common sysstat gawk
