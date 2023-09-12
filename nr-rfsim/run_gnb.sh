#!/bin/bash
docker stop rfsim5g-oai-gnb
docker rm rfsim5g-oai-gnb
docker-compose up -d oai-gnb
