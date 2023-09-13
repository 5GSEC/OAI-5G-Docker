#!/bin/bash

OAI_ROOT=/root/OAI-5G/

# Run OAI nrUE in end-to-end SA mode
cd $OAI_ROOT
source oaienv
cd cmake_targets/ran_build/build/

# Run with PHY scope
#numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./nr-uesoftmodem --dlsch-parallel 8 -d --sa --uicc0.imsi 2089900007487 --usrp-args "addr=192.168.40.2" -E --numerology 1 -r 106 --band 78 -C 3619200000 --nokrnmod 1 --ue-txgain 0 -A 2539 --clock-source 1 --time-source 1 2>&1 | tee ../../../../mylogs/UE-$(date +"%m%d%H%M").log

# Run without PHY scope
numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./nr-uesoftmodem -O ~/configs/nr-usrp/nrue.uicc.conf --dlsch-parallel 8 --sa --usrp-args "type=x300" -E --numerology 1 -r 106 --band 78 -C 3619200000 --nokrnmod 1 --ue-txgain 0 -A 2539 --ue-fo-compensation 2>&1 | tee ../../../../mylogs/NRUE-$(date +"%m%d%H%M").log
