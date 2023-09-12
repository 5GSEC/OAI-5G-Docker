# OAI-5G-Docker

## OAI compile

Build with ONOS SD-RAN RIC Agent

```
cd <OAI-ROOT>/cmake_targets
./build_oai -c --eNB --UE --gNB --nrUE --build-ric-agent -w USRP --ninja --noavx512
```

## OAI Build Docker Command 

Remember to specify `-w SIMU` or `-w USRP` in eNB / gNB / lteUE / nrUE's Docker file. 

Same for the USRP model (currently `sdr_addrs = "type=x300";`)

### LTE
```
cd <OAI-ROOT>
docker build --target ran-base --tag ran-base:latest --file docker/Dockerfile.base.ubuntu20 .
docker build --target ran-build --tag ran-build:latest --file docker/Dockerfile.build.ubuntu20 .
docker build --target oai-enb --tag oai-enb:latest --file docker/Dockerfile.eNB.ubuntu20 .
docker build --target oai-lte-ue --tag oai-lteue:latest --file docker/Dockerfile.lteUE.ubuntu20 .
```

### NR
```
cd <OAI-ROOT>
docker build --target ran-base --tag ran-base:latest --file docker/Dockerfile.base.ubuntu20 .
docker build --target ran-build --tag ran-build:latest --file docker/Dockerfile.build.ubuntu20 .
docker build --target oai-gnb --tag oai-gnb:latest --file docker/Dockerfile.gNB.ubuntu20 .
docker build --target oai-nr-ue --tag oai-nr-ue:latest --file docker/Dockerfile.nrUE.ubuntu20 .
```

### Run

Remember to specify the locally compiled image, e.g., `oai-enb:latest`

```
cd lte-rfsim / lte-usrp / nr-rfsim / rf-usrp
./run_all.sh
```

## Colosseum

### RF Scenario Setup

| ID    |                                Scenario Name             | Center Freq (GHZ)    | #Nodes | Duration(s)   |
|-------|---------------------------------------------------------:|---------|----|-----|
| 52003 |                                All Paths 0 dB - 2.54 GHz | 2.54    | 20 | 1   |
| 10012 |                                            All Paths 0dB | 2.59335 | 10 | 600 |
| 10018 |                                            All Paths 0dB | 2.63    | 10 | 10  |
| 90006 |              Channel Sounding - Increasing losses - 3GHz | 3       | 5  | 1   |
| 10016 |                                            All Paths 0dB | 3.52128 | 2  | 600 |
| 10017 |                                            All Paths 0dB | 3.52128 | 2  | 600 |
| 10021 |                                            All Paths 0dB | 3.52128 | 10 | 600 |
| 10011 |                                            All Paths 0dB | 3.6     | 10 | 600 |
| 20051 |                                  Directional 2 - 3.6 GHz | 3.6     | 5  | 1   |
| 20052 |                       Directional 3 (11 nodes) - 3.6 GHz | 3.6     | 11 | 1   |
| 20053 |                                           IAB Scenario 1 | 3.6     | 14 | 1   |
| 20054 |                                           IAB Scenario 2 | 3.6     | 14 | 1   |
| 20061 |                                     IAB White Scenario 1 | 3.6     | 11 | 1   |
| 20062 | IAB 0dB 2 Donors 2 Relays 20 UEs                         | 3.6     | 26 | 1   |
| 35004 | Cellular Rural Small 3.6 GHz Static 1 at 3.6 GHz + 51 dB | 3.6     | 13 | 1   |

NR at band 78 (Center frequency = 3.6GHZ):
```
colosseumcli rf start 10011 -c./
```

LTE at band 7 ? (Center frequency = 2.6GHZ):
```
colosseumcli rf start 10012 -c./
```

OR 10018?

### Useful commands

Download and import file
```
rsync -vP -e ssh haohuangwen@file-proxy:/share/nas/common/<base-image-name>.tar.gz <local path>
lxc image import <base-image-name>.tar.gz --alias <image-name>
```

Init
```
lxc init local:<image-name> <container-name>
lxc start <container-name>
lxc exec <container-name> /bin/bash
```

Export
```
lxc stop <container-name>
lxc publish <container-name> --alias <new-image-name>
lxc image export <new-image-name> <path to tarball>/<tarball-name>
```

Upload file (LXC and Docker)
```
rsync -vP -e ssh <image name> haohuangwen@file-proxy:/share/nas/osu-seclab/images
rsync -vP -e ssh <image name> haohuangwen@file-proxy:/share/nas/osu-seclab/push-images
```

SnapShot
```
colosseumcli snapshot <new-image-name>
```


### TODO

- Support multiple xNBs and UEs
- Support network slicing deployment
