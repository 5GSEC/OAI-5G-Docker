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

The remaining files under the colosseum folder (`run_rf.sh `) are only for setting up Colosseum-specific network settings.





### MobiExpert xApp

Please refer to the repository (https://github.com/5GSEC/mobi-expert-xapp#install-the-mobiexpert-xapp) and the 5G-Spector paper for details (https://web.cse.ohio-state.edu/~wen.423/papers/5G-Spector-NDSS24.pdf).

TBD / In progress:
- Open source
- Decouple telemetry reporting from analytics (e.g., divided into the MobiFlow Auditor (https://github.com/5GSEC/MobiFlow-Auditor), the MobiExpert xApp, and the 5G-DeepWatch xApp (https://github.com/5GSEC/5G-DeepWatch))


## Deploy an LTE network w/ RF simulation and 5G-Spector

Refer to https://github.com/OSUSecLab/5G-Spector


## Deploy a 5G network w/ RF simulation

VM

Compilation


## Deploy a 5G network w/ SDRs (USRP B210s)

VM 


## Deploy a 5G network on Colosseum

