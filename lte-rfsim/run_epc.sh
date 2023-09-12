#!/bin/bash
docker-compose up -d db_init 
echo "Sleep 30s... wait for DB to init"
sleep 30
docker-compose up -d magma_mme oai_spgwu trf_gen
