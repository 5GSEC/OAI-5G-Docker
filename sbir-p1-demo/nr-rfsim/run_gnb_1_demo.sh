#!/bin/bash
#docker-compose down oai-cu-1 oai-du-1
#docker-compose down oai-nr-ue-4 oai-nr-ue-5

docker-compose up -d oai-cu-1 oai-du-1
sleep 10s
./run_mobiflow_agent_1.sh
sleep 15s
docker-compose up -d oai-nr-ue-4
sleep 5s
docker-compose up -d oai-nr-ue-5
