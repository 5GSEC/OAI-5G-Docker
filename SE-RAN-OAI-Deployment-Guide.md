# SE-RAN OAI Deployment Guide

This guide provides instructions to quickly deploy an OAI-based 5G network, optionally with the near real-time RIC (nRT-RIC) component and xApps.

## Basic Concepts

We will use the following repositories, some of which are private to SE-RAN members only (assuming you already have access permission). They will be cross-referenced in later description.

### OAI-5G

OAI-5G (https://github.com/5GSEC/OAI-5G) is developed based on OAI's 2023.w23 version. It has multiple branches explained below:
- ***2023.w23*** is the original code branch forked from Eurecom OAI
- ***2023.w23.secsm.sdran*** is the SecSM enhanced version of Eurecom OAI (2023.w23) that supports the MobiFlow Telemetry and MobiExpert xApp (i.e., the 5G-Spector framework).
- ***2023.w23.kpm.sdran*** is the ONOS-RIC enhanced version that supports ONOS's basic KPM monitor xApp (https://github.com/onosproject/onos-kpimon)
- ***2023.w23.secsm.flexric*** is an experimental branch that will extend OAI's support to SecSM on FlexRIC.
- ***lte.attack*** is the branch with a number of layer-3 exploits (see https://github.com/5GSEC/OAI-5G/blob/lte.attack/common/attacks/attack_cliopts.h and the 5G-Spector paper for the options)
- ***nr.attack*** is the branch with the layer-3 exploits implemented on 5G

With OAI-5G, you can deploy eNB / gNB / UE / nrUE. Please pick the corresponding branch based on your needs.


### OAI-5G-Docker
OAI-5G-Docker (https://github.com/5GSEC/OAI-5G-Docker). This repo contains the necessary configuration files to quickly deploy a 5G network, e.g., locally via RFSIM or USRP, or on Colosseum.

All running instructions are integrated into a single bash script **run.sh** (https://github.com/5GSEC/OAI-5G-Docker/blob/master/colosseum/run.sh). There are four different folders with the corresponding pre-defined configurations at the root of OAI-5G-Docker (to save your time):

- ***lte-rfsim***: RF simulated LTE network (no SDR, or USRP required)
- ***lte-usrp***: RF-based LTE network (works on USRPs)
- ***nr-rfsim***: RF simulated NR (5G) network
- ***nr-usrp***: RF-based NR network

It can also be used to run different attack variants (check the script for details).

**Before you use this script, please make sure you have the following paths in run.sh pointing to the correct folders**

```
_oai_root=/root/OAI-5G
_oai_config_root=/root/OAI-5G-Docker
```

By default, the above directories will work on Colosseum. But if you use this script on another machine, please make sure they are correct. Note that some changes may be adapted according to your actual requirement and hardware (e.g., different USRPs).

The remaining files under the colosseum folder (`run_rf.sh set_ip_in_conf.sh set_route_to_cn.py`) are only for setting up Colosseum-specific network settings.


### MobiExpert xApp

Please refer to the repository (https://github.com/5GSEC/mobi-expert-xapp#install-the-mobiexpert-xapp) and the 5G-Spector paper for details (https://web.cse.ohio-state.edu/~wen.423/papers/5G-Spector-NDSS24.pdf).

TBD / In progress:
- Open source
- Decouple telemetry reporting from analytics (e.g., divided into the MobiFlow Auditor (https://github.com/5GSEC/MobiFlow-Auditor), the MobiExpert xApp, and the 5G-DeepWatch xApp (https://github.com/5GSEC/5G-DeepWatch))


## Deploy an LTE network w/ RF simulation and 5G-Spector

Refer to https://github.com/OSUSecLab/5G-Spector


## Deploy a 5G network w/ RF simulation

To deploy a 5G network w/ RF simulation, you need to first prepare a Linux machine or VM (Ubuntu recommended). Note that OAI may have some restrictions and may not work on the latest Ubuntu versions (double-check the OAI requirements before you go).

### Step 1 Clone Repositories

Clone the OAI-5G and OAI-5G-Docker repo.

### Step 2 Compile the OAI gNB and nrUE binaries

Enter the directory: ```cd OAI-5G/cmake_targets```

Run the compilation command: ```./build_oai -I --gNB --nrUE --build-ric-agent -w SIMU --ninja --noavx512```

Explanation of the arguments:
- ```-I``` indicates you will install all dependencies (only when you compile for the first time)
- ```--gNB``` indicates you will compile gNodeB
- ```--nrUE``` indicates you will compile nrUE
- ```--build-ric-agent``` indicates you will integrate the support of the ONOS-RIC (only when you choose the compatible branch)
- ```-w SIMU``` indicates you compile the RF simulation library
- ```--ninja``` to accelerate the compilation

### Step 3 Deploy the 5GC

Enter ```OAI-5G-Docker/<config_folder>```, e.g., nr-rfsim if you deploy a RF SIM 5G network. Then run:

```
./run_5gc.sh
```

Please adapt the core network configurations under ```OAI-5G-Docker/<config_folder>``` to your needs.


### Step 4 Deploy the gNB

Run

```
OAI-5G-Docker/colosseum/run.sh gnb rfsim 
```

### Step 5 Deploy (multiple) nrUEs

Run

```
OAI-5G-Docker/colosseum/run.sh nrue* rfsim 
```

```*``` indicates the index of UE (chosen from 0-9)



## Deploy a 5G network w/ SDRs (USRP B210s)

### Compilation

Run the compilation command: ```./build_oai -I --gNB --nrUE --build-ric-agent -w USRP --ninja --noavx512```

Use ```-w USRP``` instead of ```-W SIMU```

### Deployment

Similar to the RF SIM deployment, but use the ```nr-usrp``` config folder. Remove the ```rfsim``` argument when running the gNB and nrUE.


## Deploy a 5G network on Colosseum

### Step 1 Set up your Colosseum account and connect to VPN

Just follow the official guide from Colosseum and you'll be fine

You can log in to the file-proxy server to examine the docker images we've prepared, such as: 

```
ls -l /share/nas/<YOUR_ORG>/images
```


### Step 2 Schedule an appointment 

To start your experiment you will need to schedule an appointment via Colosseum's portal. You will need to reserve a number of SRNs, with the following typical settings:

- SRN#1 to deploy the 5G Core, use image ```oai-5gc-img-<DATE>.tar.gz``` 
- SRN#2 to deploy the gNodeB, use image ```oai-secsm-ran-ue-img-<DATE>.tar.gz```
- SRN#<3-X> to deploy the nrUEs (each nrUE as an independent SRN), use image ```oai-secsm-ran-ue-img-<DATE>.tar.gz```
- (Optional) SRN#Y to deploy the attacker nrUE to demonstrate the attacks. Use ```oai-attack-img-<DATE>.tar.gz```

***Please always choose the most recent images according to the DATE postfix since they are the most stable ones with the latest features***


### Step 3 Deploy the 5G Network

It is similar to how you deploy the RF SIM or RF-based 5G network as described before. 

Before you run the gNB and nrUE, run ```run_rf.sh nr78``` (it should be located under your home folder) only once on any container. The purpose is to configure the Colosseum's RF Emulator to the correct ***RF Scenario*** (otherwise the UEs won't connect to the gNB). ```nr78``` here indicates a band 78 5G network.

For other executions, use ```run.sh``` located in your home folder should be sufficient.



## Troubleshooting

Please contact Haohuang Wen (wen.423@osu.edu) if you have any questions.


