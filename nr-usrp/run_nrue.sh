#!/bin/bash
docker stop rfsim5g-oai-nr-ue
docker rm rfsim5g-oai-nr-ue
docker-compose up -d oai-nr-ue
