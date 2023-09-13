#!/bin/bash

OAI_ROOT=/root/OAI-5G/

# Add route towards core network
python3 /root/set_route_to_cn.py -i col0

# Set IP address of col0 interface as IP to bind to in gNB config file
/root/set_ip_in_conf.sh

# Run OAI gNB
cd $OAI_ROOT
source oaienv
cd cmake_targets/ran_build/build/

./lte-uesoftmodem -O ~/configs/lte-usrp/lteue.usim-ci.conf -C 2680000000 -r 25 --ue-scan-carrier --nokrnmod 1 --noS1 --ue-rxgain 120 --ue-txgain 30 --ue-max-power 0 --ue-nb-ant-tx 1 --ue-nb-ant-rx 1 --usrp-args “type=x300” -d 2>&1 | tee ../../../../mylogs/LTEUE-$(date +"%m%d%H%M").log
