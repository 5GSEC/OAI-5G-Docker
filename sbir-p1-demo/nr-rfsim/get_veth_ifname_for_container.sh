#!/bin/bash

get_veth_ifname_for_container() {
    local container_name="$1"
    
    # Check if container exists and is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "Error: Container '$container_name' not found or not running" >&2
        return 1
    fi
    
    # Get the container's interface index for eth0 (or first interface)
    local container_ifindex
    container_ifindex=$(docker exec "$container_name" sh -c 'cat /sys/class/net/eth*/iflink 2>/dev/null | head -1' 2>/dev/null)
    
    if [[ -z "$container_ifindex" ]]; then
        echo "Error: Could not get interface index from container '$container_name'" >&2
        return 1
    fi
    
    # Find the corresponding veth interface on the host
    for host_iface in /sys/class/net/veth*; do
        if [[ -e "$host_iface/ifindex" ]]; then
            local host_ifindex
            host_ifindex=$(cat "$host_iface/ifindex" 2>/dev/null)
            if [[ "$host_ifindex" == "$container_ifindex" ]]; then
                basename "$host_iface"
                return 0
            fi
        fi
    done
    
    echo "Error: No matching veth interface found for container '$container_name'" >&2
    return 1
}

# Alternative function that shows all veth pairs for a container
get_all_veth_pairs_for_container() {
    local container_name="$1"
    
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "Error: Container '$container_name' not found or not running" >&2
        return 1
    fi
    
    # Get all container interface indices
    docker exec "$container_name" sh -c '
        for iface in /sys/class/net/eth*; do
            if [[ -e "$iface/iflink" ]]; then
                ifname=$(basename "$iface")
                iflink=$(cat "$iface/iflink")
                echo "$ifname:$iflink"
            fi
        done
    ' 2>/dev/null | while IFS=: read -r container_iface container_ifindex; do
        # Find matching host veth
        for host_iface in /sys/class/net/veth*; do
            if [[ -e "$host_iface/ifindex" ]]; then
                host_ifindex=$(cat "$host_iface/ifindex" 2>/dev/null)
                if [[ "$host_ifindex" == "$container_ifindex" ]]; then
                    echo "$container_iface -> $(basename "$host_iface")"
                    break
                fi
            fi
        done
    done
}

# Usage examples:
# get_veth_ifname_for_container "my-container"
# get_all_veth_pairs_for_container "my-container"

# If script is called directly, use the first argument as container name
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <container_name>" >&2
        echo "Example: $0 my-container" >&2
        exit 1
    fi
    
    echo $(get_veth_ifname_for_container "$1")
    
    #echo -e "\nAll veth pairs:"
    #get_all_veth_pairs_for_container "$1"
fi
