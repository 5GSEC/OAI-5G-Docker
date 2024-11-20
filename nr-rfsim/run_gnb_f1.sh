#!/bin/bash
docker stop rfsim5g-oai-cu rfsim5g-oai-du
docker rm rfsim5g-oai-cu rfsim5g-oai-du
pushd 5gc
docker-compose up -d oai-cu oai-du
popd