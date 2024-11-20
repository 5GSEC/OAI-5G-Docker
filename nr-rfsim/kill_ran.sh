#!/bin/bash
# docker kill oai-ext-dn oai-spgwu oai-smf oai-amf oai-nrf mysql #$(docker ps -a -q)
# docker rm oai-ext-dn oai-spgwu oai-smf oai-amf oai-nrf mysql #$(docker ps -a -q)

docker kill rfsim5g-oai-nr-ue0 rfsim5g-oai-nr-ue1 rfsim5g-oai-du rfsim5g-oai-cu
docker rm rfsim5g-oai-nr-ue0 rfsim5g-oai-nr-ue1 rfsim5g-oai-du rfsim5g-oai-cu
