#!/bin/bash
docker stop oai-nr-ue-0 oai-nr-ue-1
docker rm oai-nr-ue-0 oai-nr-ue-1
docker-compose up -d oai-nr-ue-0
sleep 5s
docker-compose up -d oai-nr-ue-1
