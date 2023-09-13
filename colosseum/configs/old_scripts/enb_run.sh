#!/bin/bash

NB_CONFIG_PATH=~/configs/lte-usrp/enb.conf
OAI_ROOT=/root/OAI-5G/

# Add route towards core network
python3 /root/set_route_to_cn.py -i col0

# Set IP address of col0 interface as IP to bind to in gNB config file
/root/set_ip_in_conf.sh

# Run OAI gNB
cd $OAI_ROOT
source oaienv
cd cmake_targets/ran_build/build/

numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./lte-softmodem -O $NB_CONFIG_PATH --usrp-tx-thread-config 1 2>&1 | tee ../../../../mylogs/ENB-$(date +"%m%d%H%M").log
