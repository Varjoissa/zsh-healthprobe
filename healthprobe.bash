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
path_output=$(yq -r '.output_file' "$path_config" 2>/dev/null)

if [ -z "$path_output" ]; then
    path_output="/tmp/healthprobe/probes.output"
fi

if [ ! -f "$path_output" ]; then
    mkdir -p $(dirname $path_output)
    touch $path_output
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

        if [ -z "$(eval echo \$HEALTHPROBE_$name)" ]; then
            eval "HEALTHPROBE_$name=0"
        fi

        if [[ $((HEALTHPROBE_TIME-$(eval echo \$HEALTHPROBE_$name))) -ge $(($interval)) ]]; then
            output=$(cat $path_output 2>/dev/null | grep $name)
            if [ -z "$output" ]; then
                echo " $name " >> $path_output
            fi
            eval "HEALTHPROBE_$name=$HEALTHPROBE_TIME"
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