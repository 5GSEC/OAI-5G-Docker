#!/bin/bash
col0_ip=$(ip -f inet addr show col0 | grep -Po 'inet \K[\d.]+')
echo " "
echo "IP address of col0 interface of this host is ${col0_ip}"

if [ "$#" -lt 1 ]; then
    echo "CONFIG PATH NOT PROVIDED"
	exit 1
fi
NB_CONFIG_PATH=$1
echo $NB_CONFIG_PATH

if [[ $NB_CONFIG_PATH == *"lte"* ]]; then
  sed -i "/ENB_IPV4_ADDRESS_FOR_S1_MME/ c \        ENB_IPV4_ADDRESS_FOR_S1_MME              = \"$col0_ip\/24\";" $NB_CONFIG_PATH
  sed -i "/ENB_IPV4_ADDRESS_FOR_S1U/ c \        ENB_IPV4_ADDRESS_FOR_S1U                 = \"${col0_ip}\/24\";" $NB_CONFIG_PATH
  sed -i "/ENB_IPV4_ADDRESS_FOR_X2C/ c \        ENB_IPV4_ADDRESS_FOR_X2C                 = \"${col0_ip}\/24\";" $NB_CONFIG_PATH
  echo "ENB config file updated"
  echo " "
fi

if [[ $NB_CONFIG_PATH == *"nr"* ]]; then
  sed -i "/GNB_IPV4_ADDRESS_FOR_NG_AMF/ c \        GNB_IPV4_ADDRESS_FOR_NG_AMF              = \"$col0_ip\/24\";" $NB_CONFIG_PATH
  sed -i "/GNB_IPV4_ADDRESS_FOR_NGU/ c \        GNB_IPV4_ADDRESS_FOR_NGU                 = \"${col0_ip}\/24\";" $NB_CONFIG_PATH
  echo "GNB config file updated"
  echo " "
fi
