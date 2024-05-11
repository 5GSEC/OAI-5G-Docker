#!/bin/bash
docker kill oai-ext-dn oai-spgwu oai-smf oai-amf oai-nrf mysql #$(docker ps -a -q)
docker rm oai-ext-dn oai-spgwu oai-smf oai-amf oai-nrf mysql #$(docker ps -a -q)
