# SE-RAN OAI Deployment Guide

This guide provides instructions to quickly deploy an OAI-based 5G network, optionally with the near real-time RIC (nRT-RIC) component and xApps.

## I. Basic Concepts

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

All running instructions are integrated into a single bash script **run.sh** (https://github.com/5GSEC/OAI-5G-Docker/blob/master/run.sh). There are four different folders with the corresponding pre-defined configurations at the root of OAI-5G-Docker (to save your time):

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

The remaining files under the colosseum folder (`run_rf.sh` `set_ip_in_conf.sh` `set_route_to_cn.py`) are only for setting up Colosseum-specific network settings.


### MobiExpert xApp

Please refer to the repository (https://github.com/5GSEC/mobi-expert-xapp#install-the-mobiexpert-xapp) and the 5G-Spector paper for details (https://web.cse.ohio-state.edu/~wen.423/papers/5G-Spector-NDSS24.pdf).

TBD / In progress:
- Open source
- Decouple telemetry reporting from analytics (e.g., divided into the MobiFlow Auditor (https://github.com/5GSEC/MobiFlow-Auditor), the MobiExpert xApp, and the 5G-DeepWatch xApp (https://github.com/5GSEC/5G-DeepWatch))


## II. Deploy an LTE network w/ RF simulation and 5G-Spector

Refer to https://github.com/5GSEC/5G-Spector/wiki/5G%E2%80%90Spector-Artifact-in-a-Simulated-LTE-Network


## III. Deploy a 5G network w/ RF simulation from scratch

To deploy a 5G network w/ RF simulation, you need to first prepare a Linux machine or VM (Ubuntu recommended). Note that OAI may have some restrictions and may not work on the latest Ubuntu versions (double-check the OAI requirements before you go).

Recommended environment:

| Env        		| Value           	|
| ------------- 	| :-------------: 	|
| OS         		| Ubuntu 20.04 LTS 	|
| RAM      		| 8 GB      			|
| Storage 		| 100 GB				|


### Step 1 Install dependencies

#### Install docker

Refer to: https://docs.docker.com/engine/install/ubuntu/

You can add your user to the docker group to avoid running docker with sudo:

```
sudo groupadd docker
sudo gpasswd -a $USER docker
```

Log back in to let this take effect.

#### Install docker compose standalone:

Refer to: https://docs.docker.com/compose/install/standalone/

You might need to add execution permission to it:

```
sudo chmod +x /usr/local/bin/docker-compose
```



### Step 2 Deploy an OAI 5G network


#### 2.1 Clone Repositories

Clone the OAI-5G and OAI-5G-Docker repos.

```
git clone https://github.com/5GSEC/OAI-5G.git
git clone https://github.com/5GSEC/OAI-5G-Docker.git
```

#### 2.2 Compile the OAI gNB and nrUE binaries

Check out the correct branch

```
cd OAI-5G
git checkout 2023.w23.secsm.sdran
```

Enter the directory: 

```cd OAI-5G/cmake_targets```

Run the compilation command: 

```./build_oai -I --gNB --nrUE --build-ric-agent -w SIMU --ninja --noavx512```

Explanation of the arguments:

- ```-I``` indicates you will install all dependencies (only when you compile for the first time)
- ```--gNB``` indicates you will compile gNodeB
- ```--nrUE``` indicates you will compile nrUE
- ```--build-ric-agent``` indicates you will integrate the support of the ONOS-RIC (only when you choose the compatible branch)
- ```-w SIMU``` indicates you compile the RF simulation library
- ```--ninja``` to accelerate the compilation

The compilation takes a while. After a successful compilation, you will find `nr-softmodem` and `nr-uesoftmodem` under `<PATH_TO_OAI-5G>/cmake_targets/ran_build/build/`.

#### 2.3 Deploy the 5GC

Enter ```OAI-5G-Docker/<config_folder>```, e.g., nr-rfsim if you deploy a RF SIM 5G network. Then run:

```
./run_5gc.sh
```

Please adapt the core network configurations under ```OAI-5G-Docker/<config_folder>``` to your needs.

Wait to verify OAI 5GC deployment (all containers up and in `healthy` status):

```
$ docker ps -a
CONTAINER ID   IMAGE                                       COMMAND                  CREATED         STATUS                   PORTS                          NAMES
88ca47d70254   oaisoftwarealliance/trf-gen-cn5g:focal      "/bin/bash -c ' ipta…"   7 minutes ago   Up 6 minutes (healthy)                                  oai-ext-dn
56c1f343af58   oaisoftwarealliance/oai-spgwu-tiny:v1.5.0   "python3 /openair-sp…"   7 minutes ago   Up 6 minutes (healthy)   2152/udp, 8805/udp             oai-spgwu
5606bcf24c1e   oaisoftwarealliance/oai-smf:v1.5.0          "python3 /openair-sm…"   7 minutes ago   Up 6 minutes (healthy)   80/tcp, 8080/tcp, 8805/udp     oai-smf
4ee38fd67d47   oaisoftwarealliance/oai-amf:v1.5.0          "python3 /openair-am…"   7 minutes ago   Up 7 minutes (healthy)   80/tcp, 9090/tcp, 38412/sctp   oai-amf
e7c166989cb4   mysql:8.0                                   "docker-entrypoint.s…"   7 minutes ago   Up 7 minutes (healthy)   3306/tcp, 33060/tcp            mysql
08ed0bea0da3   oaisoftwarealliance/oai-nrf:v1.5.0          "python3 /openair-nr…"   7 minutes ago   Up 7 minutes (healthy)   80/tcp, 9090/tcp               oai-nrf

```

To undeploy the 5GC, run:

```
./kill.sh
```


#### 2.4 Deploy the gNB

You can create a copy of the `run.sh` script to your working folder with:

```
cp OAI-5G-Docker/run.sh ~/
```

Adapt the following lines to the correct system paths to `OAI-5G` and `OAI-5G-Docker` you just crawled.

```
_oai_root=<PATH_TO_OAI-5G>
_oai_config_root=<PATH_TO_OAI-5G-Docker>
```

Run

```
sudo ~/run.sh gnb rfsim 
```

To verify GNB is running, you will see repeated log entries:

```
[NR_MAC]   Frame.Slot 128.0
```

There will be error message like:

```
[RIC_AGENT]   ranid 0 connecting to RIC at 192.168.84.144:36421 with IP 192.168.200.21 (my addr: 192.168.200.21)
```

It can be safely ignored at this momment since we haven't deployed the nRT-RIC yet.


#### 2.5 Deploy (multiple) nrUEs

Open a new terminal and run:

```
sudo ~/run.sh nrue* rfsim 
```

`*` indicates the index of UE (chosen from 0-9)

Verify the UE is running and connected to the gNB with logs like:

```
[NAS]   [UE] Received REGISTRATION ACCEPT message
...
[NR_PHY]   ============================================
[NR_PHY]   Harq round stats for Downlink: 16/0/0
[NR_PHY]   ============================================
[NR_PHY]   RSRP = -92 dBm
[NR_PHY]   RSRP = -92 dBm
[NR_PHY]   RSRP = -41 dBm
```

Logs and pcaps of each run will be saved at: `/logs/`. The configs of the UEs are available at `OAI-5G-Docker/rfsim/nr-ues`

To verify the UE's data traffic, use the created tunnel `oaitun_ue1`:

```
ping -I oaitun_ue1 -c 10 www.lemonde.fr
PING lemonde.map.fastly.net (146.75.82.217) from 12.1.1.5 oaitun_ue1: 56(84) bytes of data.
64 bytes from 146.75.82.217 (146.75.82.217): icmp_seq=1 ttl=49 time=19.6 ms
64 bytes from 146.75.82.217 (146.75.82.217): icmp_seq=2 ttl=49 time=20.8 ms
64 bytes from 146.75.82.217 (146.75.82.217): icmp_seq=3 ttl=49 time=22.8 ms
64 bytes from 146.75.82.217 (146.75.82.217): icmp_seq=4 ttl=49 time=22.8 ms
64 bytes from 146.75.82.217 (146.75.82.217): icmp_seq=5 ttl=49 time=20.2 ms
```


### 3 Deploy the nRT-RIC

Pull the SD-RAN in a Box repo:

```
git clone https://github.com/onosproject/sdran-in-a-box
```

Deploy the nRT-RIC component:

```
cd sdran-in-a-box
make OPT=ric
```

It takes a while to deploy. To verify, make sure all the pods and their containers are in `Running` status.

```
$ kubectl get pods -n riab
NAME                           READY   STATUS    RESTARTS   AGE
onos-a1t-68c59fb46-bfpks       2/2     Running   0          2m25s
onos-cli-c7d5b54b4-vjkxm       1/1     Running   0          2m25s
onos-config-5786dbc85c-pxf2s   3/3     Running   0          2m25s
onos-e2t-5798f554b7-znjf7      2/2     Running   0          2m25s
onos-kpimon-555c9fdb5c-jx2bb   2/2     Running   0          2m25s
onos-rsm-7b6d84b5fc-cnkpc      2/2     Running   0          2m25s
onos-topo-6b59c97579-d54pm     2/2     Running   0          2m25s
onos-uenib-6f65dc66b4-jz6zm    2/2     Running   0          2m25s
sd-ran-consensus-0             1/1     Running   0          2m25s
sd-ran-consensus-1             1/1     Running   0          2m25s
sd-ran-consensus-2             1/1     Running   0          2m25s
```

To undeploy, simply `make reset-ric`, or `make reset-test` to clean the whole environment.


### 4 Deploy 5G-Spector


### 5 Exploitation Testing

Refer to [Exploitation Testing](#Exploitation-Testing)


## IV. Deploy a 5G network w/ SDRs (USRP B210s)

### Compilation

Run the compilation command: ```./build_oai -I --gNB --nrUE --build-ric-agent -w USRP --ninja --noavx512```

Use ```-w USRP``` instead of ```-W SIMU```

### Deployment

Similar to the RF SIM deployment, but use the ```nr-usrp``` config folder. Remove the ```rfsim``` argument when running the gNB and nrUE.


## V. Deploy a 5G network on Colosseum

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


### Kubernetes on Colosseum

As of 2024.1, deploying Kubernetes on Colosseum is still very challenging as Colosseum is a LXC container-based platform, as described in the Colosseum Q&A. As a result, deploying the ONOS-RIC on Colosseum has not been viable so far. One alternative is to deploy FlexRIC that does not require Kubernetes, which is under development.

Another option is to convert the Kubernetes deployment of the ONOS-RIC containers into a pure docker environment.


## Exploitation Testing

OAI-5G (https://github.com/5GSEC/OAI-5G) contains two branches for demonstrating a number of Layer-3 attacks (see https://github.com/5GSEC/OAI-5G/blob/lte.attack/common/attacks/attack_cliopts.h and the 5G-Spector paper for the options). They can run on both LTE networks and 5G networks. 

To compile, simply run (for LTE networks):
```
cd OAI-5G
git checkout lte.attack
./EKBuildOAIUE.sh att lte
```

For 5G networks, run:
```
cd OAI-5G
git checkout nr.attack
./EKBuildOAIUE.sh att nr
```

You may need to modify this line (https://github.com/5GSEC/OAI-5G/blob/nr.attack/EKBuildOAIUE.sh#L98) if you want to compile the attack binaries in other modes (e.g., ```-w SIMU```). Kudos to Martin Fong @ SRI for providing this script. 

You can then use the ```run.sh``` script to run the attacks, by specifying the attack parameters. For example:

```
./run.sh nr-attack rfsim --bts-attack 300 --bts-delay 100
```

Again, please refer to https://github.com/5GSEC/OAI-5G/blob/lte.attack/common/attacks/attack_cliopts.h to learn about the supported exploits.



TODO:
- Modularize the attack implementations with vendor-independent scripts and libraries. Refer to the 5Ghoul framework (https://github.com/asset-group/5ghoul-5g-nr-attacks)
- Better attack and parameter descriptions
- More attacks


## Troubleshooting

Please contact Haohuang Wen (wen.423@osu.edu) if you have any questions.


