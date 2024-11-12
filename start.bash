#!/bin/bash

# CONFIG
if [ -z "$1" ]; then
    export path_config="${HOME}/.config/healthprobe/config.yaml"
else
    export path_config=$1
fi

export path_pid="/tmp/healthprobe/healthprobe.pid"

if [ ! -f "$path_config" ]; then
    mkdir -p $(dirname $path_config)
    cat <<EOF > $path_config
store_file: /tmp/healthprobe/probes.store

polling_interval: 1

probes:
    - name: TEST
      interval: 10
      action: store
      reset_if: retrieved
EOF
fi

if [ ! -d $(dirname $path_pid) ]; then
    mkdir -p $(dirname $path_pid)
fi

# FUNCTIONS

healthprobe_check_item() {
    config=$1
    item=$2

    [ -z "$config" ] && echo "ERROR: Config file not provided" >&2 && return 1
    [ ! -f "$config" ] && echo "ERROR: Config file not found" >&2 && return 1
    [ -z "$item" ] && echo "ERROR: Item not provided" >&2 && return 1

    local store_file="$(yq -r '.store_file' "$config" 2>/dev/null)"
    ITEM_EXISTS=$(cat $store_file 2>/dev/null | grep " $item ")

    [ -n "$ITEM_EXISTS" ] && echo "$item"
    
    return 0
}

healthprobe_get_store() {
    config=$1

    [ -z "$config" ] && echo "ERROR: Config file not provided" >&2 && return 1
    [ ! -f "$config" ] && echo "ERROR: Config file not found" >&2 && return 1

    local store_file="$(yq -r '.store_file' "$config" 2>/dev/null)"
    echo $(cat $store_file 2>/dev/null)
}

healthprobe_retrieve() {
    config=$1
    item=$2

    [ -z "$config" ] && echo "ERROR: Config file not provided" >&2 && return 1
    [ ! -f "$config" ] && echo "ERROR: Config file not found" >&2 && return 1
    [ -z "$item" ] && echo "ERROR: Item not provided" >&2 && return 1

    local store_file="$(yq -r '.store_file' "$config" 2>/dev/null)"
    ITEM_EXISTS=$(cat $store_file 2>/dev/null | grep " $item ")

    if [ -n "$ITEM_EXISTS" ]; then
        echo "$item"
        sed -i '' "/ $item /d" $store_file
    fi

    return 0
}
alias hpack="healthprobe_retrieve $path_config"

healthprobe_running() {
    pid_file=$1

    [ -z "$pid_file" ] && echo "false"
    [ ! -f "$pid_file" ] && echo "false"

    local pid=$(cat $pid_file)
    local pid_exists=$(ps -p $pid | grep "healthprobe.bash")

    if [ -n "$pid_exists" ]; then
        echo "true"
    else
        echo "false"
    fi
    return 0
}

healthprobe_start() {
    path_config=$1
    path_pid=$2

    [ -z "$path_config" ] && echo "ERROR: Config file not provided" >&2 && return 1
    [ ! -f "$path_config" ] && echo "ERROR: Config file not found" >&2 && return 1
    [ -z "$path_pid" ] && echo "ERROR: PID file not provided" >&2 && return 1
    
    bash ./healthprobe.bash $path_config &
    HEALTHPROBE_PID=$!
    echo $HEALTHPROBE_PID > $path_pid
    echo "Healthprobe started..."
}

healthprobe_stop() {
    healthprobe_pid=$1
    config=$2

    [ -z "$healthprobe_pid" ] && echo "ERROR: PID file not provided" >&2 && return 1
    [ -z "$config" ] && echo "ERROR: Config file not provided" >&2 && return 1
    [ ! -f "$healthprobe_pid" ] && echo "ERROR: PID file not found" >&2 && return 1
    [ ! -f "$config" ] && echo "ERROR: Config file not found" >&2 && return 1

    if [ -f $healthprobe_pid ]; then
        kill -9 $(cat $healthprobe_pid)
        rm -f $healthprobe_pid
        rm -f $(yq -r '.store_file' "$config" 2>/dev/null)
        echo "Healthprobe stopped..."
    fi
}
alias hpstop="healthprobe_stop $path_pid $path_config"


# MAIN

# Check if healthprobe is already running
if [[ $(healthprobe_running $path_pid) == "true" ]]; then
    echo "Healthprobe already running..."
else
    rm -f $path_pid
    healthprobe_start $path_config $path_pid
fi

unset path_config
unset path_pid