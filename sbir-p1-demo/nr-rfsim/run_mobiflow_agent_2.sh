#!/bin/bash

# This script runs the Mobiflow agent with the discovered interfaces from OAI CU and DU.

source get_veth_ifname_for_container.sh

# Discover interfaces
cu_if=$(get_veth_ifname_for_container rfsim5g-oai-cu2) # adapt the cu container name if needed
du_if=$(get_veth_ifname_for_container rfsim5g-oai-du2) # adapt the du container name if needed

if [[ -z "$cu_if" || -z "$du_if" ]]; then
  echo "Could not discover both interfaces."
  exit 1
fi

echo "Found CU: $cu_if, DU: $du_if"
echo "Running agent with: $cu_if $du_if"

MOBIFLOW_COMMAND="$cu_if $du_if" docker-compose up -d mobiflow-agent-2
