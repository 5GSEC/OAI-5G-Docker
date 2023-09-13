#!/bin/bash

NB_CONFIG_PATH=/root/configs/nr-usrp/gnb.conf
OAI_ROOT=/root/OAI-5G/

# Add route towards core network
python3 /root/set_route_to_cn.py -i col0

# Set IP address of col0 interface as IP to bind to in gNB config file
/root/set_ip_in_conf.sh

# Run OAI gNB
cd $OAI_ROOT
source oaienv
cd cmake_targets/ran_build/build/

# Run without PHY scope
#sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf --sa -E --usrp-tx-thread-config 1 2>&1 | tee ../../../../mylogs/GNB-$(date +"%m%d%H%M").log
numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0  ./nr-softmodem -O $NB_CONFIG_PATH --sa -E --gNBs.[0].min_rxtxtime 6 --sa --usrp-tx-thread-config 1 -E --continuous-tx 2>&1 | tee ../../../../mylogs/GNB-$(date +"%m%d%H%M").log
