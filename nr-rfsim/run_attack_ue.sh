#!/bin/bash
docker stop rfsim5g-oai-attack-ue
docker rm rfsim5g-oai-attack-ue
docker-compose up -d oai-attack-ue-1
sleep 1s
docker-compose up -d oai-attack-ue-2
