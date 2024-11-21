#!/bin/bash
docker stop rfsim5g-oai-nr-ue-0 rfsim5g-oai-nr-ue-1
docker rm rfsim5g-oai-nr-ue-0 rfsim5g-oai-nr-ue-1
docker-compose up -d oai-nr-ue-0
sleep 5s
docker-compose up -d oai-nr-ue-1
