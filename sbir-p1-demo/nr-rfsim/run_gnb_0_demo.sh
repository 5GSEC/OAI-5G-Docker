#!/bin/bash
#docker-compose down oai-cu-0 oai-du-0
#docker-compose down oai-nr-ue-0 oai-nr-ue-1 oai-nr-ue-2 oai-nr-ue-3 oai-nr-ue-3

docker-compose up -d oai-cu-0 oai-du-0
sleep 15s
sudo ./run_mobiflow_agent_0.sh
sleep 15s
docker-compose up -d oai-nr-ue-0
sleep 5s
docker-compose up -d oai-nr-ue-1
sleep 5s
docker-compose up -d oai-nr-ue-2
sleep 5s
docker-compose up -d oai-nr-ue-3
