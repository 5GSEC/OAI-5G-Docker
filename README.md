# OAI-5G-Docker

This repository stores the configuration files to build OAI LTE / 5G networks.

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

## TODO

- Support multiple xNBs and UEs
- Support network slicing deployment
- Support ONOS SD-RAN RIC Agent (w/ SECSM)
- Support FlexRIC
