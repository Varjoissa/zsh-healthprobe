#!/bin/bash

# CONFIG
if [ -z "$1" ]; then
    export path_config="${HOME}/.config/healthprobe/config.yaml"
    path_pid="${HOME}/.config/healthprobe/healthprobe.pid"
else
    export path_config=$1
    path_pid="$(dirname $path_config)/healthprobe.pid"
fi

if [ ! -f "$path_config" ]; then
    mkdir -p $(dirname $path_config)
    cat <<EOF > $path_config
store_file: /tmp/healthprobe/probes.store
polling_interval: 1
probes:
    - name: TEST
      interval: 10
EOF
fi

# FUNCTIONS

healthprobe_get_store() {
    config=$1
    local store_file="$(yq -r '.store_file' "$config" 2>/dev/null)"
    echo $(cat $store_file 2>/dev/null)
}
alias hpo="healthprobe_get_store $path_config"

healthprobe_retrieve() {
    config=$1
    item=$2
    local store_file="$(yq -r '.store_file' "$config" 2>/dev/null)"
    ITEM_EXISTS=$(cat $store_file 2>/dev/null | grep " $item ")

    if [ -n "$ITEM_EXISTS" ]; then
        echo "$item"
        sed -i '' "/ $item /d" $store_file
    fi

    return 0
}
alias hpr="healthprobe_retrieve $path_config"

healthprobe_stop() {
    healthprobe_pid=$1
    config=$2
    if [ -f $healthprobe_pid ]; then
        kill -9 $(cat $healthprobe_pid)
        rm -f $healthprobe_pid
        rm -f $(yq -r '.store_file' "$config" 2>/dev/null)
        echo "Healthprobe stopped..."
    fi
}
alias hps="healthprobe_stop $path_pid $path_config"

healthprobe_start() {
    bash ./healthprobe.bash $path_config &
    HEALTHPROBE_PID=$!
    echo $HEALTHPROBE_PID > $path_pid
    echo "Healthprobe started..."
}

# MAIN

# Check if healthprobe is already running
if [ -f $path_pid ]; then
    HEALTHPROBE_PID_EXISTS=$(ps -p $(cat $path_pid) | grep "healthprobe.bash")
else
    HEALTHPROBE_PID_EXISTS=""
fi

if [ -n "$HEALTHPROBE_PID_EXISTS" ]; then
    echo "Healthprobe already running..."
else
    rm -f $path_pid
    healthprobe_start
fi

unset path_config
unset path_pid