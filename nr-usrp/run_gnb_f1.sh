#!/bin/bash
docker stop oai-cu oai-du
docker rm oai-cu oai-du
docker-compose up -d oai-cu oai-du
