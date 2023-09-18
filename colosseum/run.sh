#!/bin/bash

_config_path=""
_oai_root=/root/OAI-5G/
_log_path=/logs/logs/
_pcap_path=/logs/pcaps/
_prefix=""
_pcap_args=""
_pcap_enabled=true
_find_route=false
_cmd=""

mkdir -p $_log_path
mkdir -p $_pcap_path

while [ -n "$1" ]; do
    _arg="$1"; shift
    case "$_arg" in
        0|enb)
            _find_route=true
            _prefix="ENB"
            _config_path="/root/OAI-5G-Docker/lte-usrp/enb.conf"
            _common_args="-O $_config_path --usrp-tx-thread-config 1"
            _exec_path="./lte-softmodem"
            ;;
        1|lteue)
            _find_route=false
            _prefix="LTEUE"
            _usrp_args="type=x300"
            _config_path="/root/OAI-5G-Docker/lte-usrp/lteue.usim-ci.conf"
            _common_args="-O $_config_path -C 2680000000 -r 25 --ue-scan-carrier --nokrnmod 1 --noS1 --ue-rxgain 120 --ue-txgain 30 --ue-max-power 0 --ue-nb-ant-tx 1 --ue-nb-ant-rx 1 --usrp-args \"$_usrp_args\" -d"
            _exec_path="numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./lte-uesoftmodem"
            ;;
        2|gnb)
            _find_route=true
            _prefix="GNB"
            _config_path="/root/OAI-5G-Docker/nr-usrp/gnb.conf"
            _common_args="-O $_config_path --sa -E --gNBs.[0].min_rxtxtime 6 --usrp-tx-thread-config 1 -E --continuous-tx 1"
            _exec_path="./nr-softmodem"
            ;;
        3|gnb-cu)
            _find_route=true
            _prefix="GNB-CU"
            _config_path="/root/OAI-5G-Docker/nr-usrp/gnb-cu.conf"
            _common_args="-O $_config_path --sa -E --gNBs.[0].min_rxtxtime 6"
            _exec_path="./nr-softmodem"
            ;;
        4|gnb-du)
            _find_route=true
            _prefix="GNB-DU"
            _config_path="/root/OAI-5G-Docker/nr-usrp/gnb-du.conf"
            _common_args="-O $_config_path --sa -E --gNBs.[0].min_rxtxtime 6 --usrp-tx-thread-config 1 -E --continuous-tx 1"
            _exec_path="./nr-softmodem"
            ;;
        5|nrue*)
            _find_route=false
            _prefix="NR-UE"
            _config_path="/root/OAI-5G-Docker/nr-usrp/nr-ues/$_arg.uicc.conf"
            _usrp_args="type=x300"
            _common_args="-O $_config_path --dlsch-parallel 8 --sa --usrp-args \"$_usrp_args\" -E --numerology 1 -r 106 --band 78 -C 3619200000 --nokrnmod 1 --ue-txgain 0 -A 2539 --ue-fo-compensation 1"
            _exec_path="numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./nr-uesoftmodem"
            ;;
	6|nrue-att-bts)
            _find_route=false
            _prefix="NR-UE-Attack"
            _config_path="/root/OAI-5G-Docker/nr-usrp/nr-ues/nrue0.uicc.conf"
            _usrp_args="type=x300"
			_attack_args="bts-attack 100"
            _common_args="$_attack_args -O $_config_path --dlsch-parallel 8 --sa --usrp-args \"$_usrp_args\" -E --numerology 1 -r 106 --band 78 -C 3619200000 --nokrnmod 1 --ue-txgain 0 -A 2539 --ue-fo-compensation 1"
            _exec_path="numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./nr-uesoftmodem.attack"
            ;;
        *)
            echo "ERROR: unrecognized option: \"$_arg\"."
            exit 1
            ;;
    esac
done

## Find route to core
if $_find_route; then
    cd /root/
    # Add route towards core network
    python3 /root/set_route_to_cn.py -i col0
    # Set IP address of col0 interface as IP to bind to in gNB config file
    /root/set_ip_in_conf.sh $_config_path
fi

## Check if pcap is enabled
if $_pcap_enabled; then
    _pcap_args="--opt.type pcap --opt.path $_pcap_path/${_prefix}-$(date +"%m%d%H%M").pcap"
fi

## RUN
cd $_oai_root
source oaienv
cd cmake_targets/ran_build/build/
echo "$_exec_path $_common_args"
$_exec_path $_common_args $_pcap_args 2>&1 | tee $_log_path/${_prefix}-$(date +"%m%d%H%M").log
