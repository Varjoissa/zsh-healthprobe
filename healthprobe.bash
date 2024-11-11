#!/bin/bash

path_probes=$1
path_output=$2

# If path_probes isnt set or doesnt exist, return
if [ -z "$path_probes" ] || [ ! -f "$path_probes" ]; then
    echo "Usage: healthprobe path_probes path_current path_output" >&2
    exit 1
fi

if [ ! -f "$path_output" ]; then
    mkdir -p $(dirname $path_output)
    touch $path_output
fi

HEALTHPROBE_TIME=0

while true; do
    HEALTHPROBE_TIME=$((HEALTHPROBE_TIME+1))
    
    for line in $(cat $path_probes); do
        item=$(echo $line | cut -d= -f1)
        treshold=$(echo $line | cut -d= -f2)

        if [ -z "$(eval echo \$HEALTHPROBE_$item)" ]; then
            eval "HEALTHPROBE_$item=$HEALTHPROBE_TIME"
            continue
        fi

        if [[ $((HEALTHPROBE_TIME-$(eval echo \$HEALTHPROBE_$item))) -gt $(($treshold)) ]]; then
            output=$(cat $path_output | grep $item 2>/dev/null)
            if [ -z "$output" ]; then
                echo "$item" >> $path_output
                echo " .. $item is added"
            else
                echo " .. $item is already there"
            fi
            eval "HEALTHPROBE_$item=$HEALTHPROBE_TIME"
        fi

        item=""
        treshold=""
        output=""
    done
    
    sleep 1
done