#!/bin/bash
# docker kill oai-ext-dn oai-spgwu oai-smf oai-amf oai-nrf mysql #$(docker ps -a -q)
# docker rm oai-ext-dn oai-spgwu oai-smf oai-amf oai-nrf mysql #$(docker ps -a -q)

docker kill oai-upf oai-smf oai-amf oai-ausf oai-udm oai-udr mysql oai-nrf oai-ext-dn
docker rm oai-upf oai-smf oai-amf oai-ausf oai-udm oai-udr mysql oai-nrf oai-ext-dn