#!/bin/bash

docker-compose up -d oai-cu-0 oai-du-0
sleep 5s
docker-compose up -d oai-cu-1 oai-du-1
sleep 5s
docker-compose up -d oai-cu-2 oai-du-2
