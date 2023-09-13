#!/bin/bash

_config_path=/root/configs/nr-usrp/gnb.conf
_oai_root=/root/OAI-5G/
_log_path=../../../../mylogs
_pcap_path=../../../../mylogs
_find_route=false
_cmd=""

while [ -n "$1" ]; do
    _arg="$1"; shift
    case "$_arg" in
    	0|enb)
			_find_route=true
			_config_path="/root/configs/lte-usrp/enb.conf"
			_common_args="-O $_config_path --usrp-tx-thread-config 1 2>&1 --opt.type pcap --opt.path $_pcap_path/ENB-$(date +"%m%d%H%M").pcap | tee $_log_path/ENB-$(date +"%m%d%H%M").log"
			_exec_path="./lte-softmodem"
			#_cmd="numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./lte-softmodem $_common_args"
            ;;
        1|lteue)
			_find_route=false
			_usrp_args="type=x300"
			_config_path="/root/configs/lte-usrp/lteue.usim-ci.conf"
			_common_args="-O $_config_path -C 2680000000 -r 25 --ue-scan-carrier --nokrnmod 1 --noS1 --ue-rxgain 120 --ue-txgain 30 --ue-max-power 0 --ue-nb-ant-tx 1 --ue-nb-ant-rx 1 --usrp-args \"$_usrp_args\" -d 1 2>&1 --opt.type pcap --opt.path $_pcap_path/LTEUE-$(date +"%m%d%H%M").pcap | tee ../../../../mylogs/LTEUE-$(date +"%m%d%H%M").log"
			_exec_path="./lte-uesoftmodem"
			# _cmd="./lte-uesoftmodem $_common_args"
			;;
		2|gnb)
			_find_route=true
			_config_path="/root/configs/nr-usrp/gnb.conf"
			_common_args="-O $_config_path --sa -E --gNBs.[0].min_rxtxtime 6 --sa --usrp-tx-thread-config 1 -E --continuous-tx 1 2>&1 --opt.type pcap --opt.path $_pcap_path/GNB-$(date +"%m%d%H%M").pcap | tee ../../../../mylogs/GNB-$(date +"%m%d%H%M").log"
			_exec_path="./nr-softmodem"
			#_cmd="numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./nr-softmodem $_common_args"
			;;
		3|nrue)
			_find_route=false
			_config_path="/root/configs/nr-usrp/nrue.uicc.conf"
			_usrp_args="type=x300"
			_common_args="-O $_config_path --dlsch-parallel 8 --sa --usrp-args \"$_usrp_args\" -E --numerology 1 -r 106 --band 78 -C 3619200000 --nokrnmod 1 --ue-txgain 0 -A 2539 --ue-fo-compensation 1 2>&1 --opt.type pcap --opt.path $_pcap_path/NRUE-$(date +"%m%d%H%M").pcap | tee ../../../../mylogs/NRUE-$(date +"%m%d%H%M").log"
			_exec_path="./nr-uesoftmodem"
			#_cmd="numactl --cpunodebind=netdev:usrp0 --membind=netdev:usrp0 ./nr-uesoftmodem $_common_args"
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
	/root/set_ip_in_conf.sh
fi

## RUN
cd $_oai_root
source oaienv
cd cmake_targets/ran_build/build/
$_exec_path $_common_args

