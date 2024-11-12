#
# Healthprobe
#
# Healthprobe is a supa-dupa cool tool for making you development easier.
# Link: https://www.healthprobe.xyz

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_HEALTHPROBE_SHOW="${SPACESHIP_HEALTHPROBE_SHOW=true}"
SPACESHIP_HEALTHPROBE_ASYNC="${SPACESHIP_HEALTHPROBE_ASYNC=true}"
SPACESHIP_HEALTHPROBE_PREFIX="${SPACESHIP_HEALTHPROBE_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_HEALTHPROBE_SUFFIX="${SPACESHIP_HEALTHPROBE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_HEALTHPROBE_SYMBOL="${SPACESHIP_HEALTHPROBE_SYMBOL="🔴 "}"
SPACESHIP_HEALTHPROBE_COLOR="${SPACESHIP_HEALTHPROBE_COLOR="red"}"
SPACESHIP_HEALTHPROBE_CONFIG_PATH="${SPACESHIP_HEALTHPROBE_CONFIG_PATH="${HOME}/.config/healthprobe/config.yaml"}"
SPACESHIP_HEALTHPROBE_PID_PATH="${SPACESHIP_HEALTHPROBE_PID_PATH="/tmp/healthprobe/healthprobe.pid"}"
SPACESHIP_HEALTHPROBE_RETRIEVE="${SPACESHIP_HEALTHPROBE_RETRIEVE=""}"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

# Uncomment the following functions only if you are running this script
# in a different shell context as the healthprobe start.bash script.
# When sourcing both scripts in the same shell context, the functions
# will be already available.

# healthprobe_running() {
#     pid_file=$1

#     [ -z "$pid_file" ] && echo "false" && return 0
#     [ ! -f "$pid_file" ] && echo "false" && return 0

#     local pid=$(cat $pid_file)
#     local pid_exists=$(ps -p $pid | grep "healthprobe.bash")

#     if [ -n "$pid_exists" ]; then
#         echo "true"
#     else
#         echo "false"
#     fi
#     return 0
# }

# healthprobe_retrieve() {
#     config=$1
#     item=$2

#     [ -z "$config" ] && echo "ERROR: Config file not provided" >&2 && return 1
#     [ ! -f "$config" ] && echo "ERROR: Config file not found" >&2 && return 1
#     [ -z "$item" ] && echo "ERROR: Item not provided" >&2 && return 1

#     local store_file="$(yq -r '.store_file' "$config" 2>/dev/null)"
#     ITEM_EXISTS=$(cat $store_file 2>/dev/null | grep " $item ")

#     if [ -n "$ITEM_EXISTS" ]; then
#         echo "$item"
#         sed -i '' "/ $item /d" $store_file
#     fi

#     return 0
# }


# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show healthprobe status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_healthprobe() {
    # If SPACESHIP_HEALTHPROBE_SHOW is false, don't show healthprobe section
    [[ $SPACESHIP_HEALTHPROBE_SHOW == false ]] && return
    [ -z "$SPACESHIP_HEALTHPROBE_RETRIEVE" ] && return
    
    hp_running=$(healthprobe_running "$SPACESHIP_HEALTHPROBE_PID_PATH")
    echo "HP_RUNNING: $hp_running"

    [[ "$hp_running" != "true" ]] && return

    healthprobe_block=""

    # Get all RETRIEVE items, which are seperated by space, comma or semicolon
    items=($(echo "$SPACESHIP_HEALTHPROBE_RETRIEVE" | tr ' ,;' '\n'))
    for item in "${items[@]}"; do
        retrieved_item=$(healthprobe_check_item "$SPACESHIP_HEALTHPROBE_CONFIG_PATH" "$item")
        [[ -z "$retrieved_item" ]] && continue
        healthprobe_block+="$retrieved_item "
    done

    [[ "$healthprobe_block" == "" ]] && return

    # Display healthprobe section
    # spaceship::section utility composes sections. Flags are optional
    spaceship::section::v4 \
      --color "$SPACESHIP_HEALTHPROBE_COLOR" \
      --prefix "$SPACESHIP_HEALTHPROBE_PREFIX" \
      --suffix "$SPACESHIP_HEALTHPROBE_SUFFIX" \
      --symbol "$SPACESHIP_HEALTHPROBE_SYMBOL" \
      "$healthprobe_block"
}