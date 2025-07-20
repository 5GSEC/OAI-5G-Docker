#!/bin/bash
#docker-compose down oai-cu-2 oai-du-2
#docker-compose down oai-nr-ue-6 oai-blind-dos-ue-victim oai-blind-dos-ue-attacker

docker-compose up -d oai-cu-2 oai-du-2
sleep 15s
./run_mobiflow_agent_2.sh
sleep 15s
docker-compose up -d oai-nr-ue-6 
sleep 5s
docker-compose up -d oai-blind-dos-ue-victim
sleep 30s
docker-compose up -d oai-blind-dos-ue-attacker 
