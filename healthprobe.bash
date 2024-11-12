#!/bin/bash

path_config=$1

# VALIDATION
if [ ! -f "$path_config" ]; then
    echo "ERROR: Config file not found" >&2
    echo "Usage: healthprobe path_config" >&2
    exit 1
elif [ -z "$(which yq)" ]; then
    echo "ERROR: 'yq' is not installed" >&2
    exit 1
fi

# INIT
path_store=$(yq -r '.store_file' "$path_config" 2>/dev/null)

if [ -z "$path_store" ]; then
    path_store="/tmp/healthprobe/probes.store"
fi

if [ ! -f "$path_store" ]; then
    mkdir -p $(dirname $path_store)
    touch $path_store
fi

HEALTHPROBE_TIME=0


# MAIN
while true; do
    
    # PROBES
    num_probes=$(yq -r '.probes | length' "$path_config")
    for ((i=0; i<num_probes; i++)); do
        probe=$(yq -r ".probes[$i]" "$path_config" -o json)
        name=$(echo $probe | yq -r '.name')
        interval=$(echo $probe | yq -r '.interval')
        action=$(echo $probe | yq -r '.action')
        reset_if=$(echo $probe | yq -r '.reset_if' 2>/dev/null)

        if [ -z "$(eval echo \$HEALTHPROBE_$name)" ]; then
            eval "HEALTHPROBE_$name=0"
        fi

        if [[ $((HEALTHPROBE_TIME-$(eval echo \$HEALTHPROBE_$name))) -ge $(($interval)) ]]; then
            
            case $action in
                store)
                    source ./actions/store.sh
                    ;;
                *)
                    ;;
            esac

            eval "HEALTHPROBE_$name=$HEALTHPROBE_TIME"
        else

            case $action in
                store)
                    case $reset_if in
                        retrieved)
                            if [[ $(cat $path_store 2>/dev/null | grep $name) ]]; then
                                eval "HEALTHPROBE_$name=$HEALTHPROBE_TIME"
                            fi
                            ;;
                        *)
                            ;;
                    esac
                    ;;
                *)
                    ;;
            esac
        fi

    done
    
    # SLEEP
    polling_interval=$(yq -r '.polling_interval' "$path_config")
    if [ $polling_interval -gt 0 ]; then
        sleep $polling_interval
        HEALTHPROBE_TIME=$((HEALTHPROBE_TIME+polling_interval))
    else
        sleep 1
        HEALTHPROBE_TIME=$((HEALTHPROBE_TIME+1))
    fi

done