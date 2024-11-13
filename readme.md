# Healthprobe

This is a simple background process that polls configured health probes and takes the required action.
Additionally, it can be used as a `spaceship` plugin to add the status of a health probe to the spaceship prompt.

[Click here for the spaceship plugin documentation](https://github.com/spaceship-prompt/spaceship-prompt)

---

## Installation


### Healthprobe

To install the healthprobe background process, follow these steps:


1. Clone the repository to your local machine. 

```bash
git clone <REPOSITORY> <DESTINATION>
```

2. Create a configuration file (Default location is `~/.config/healthprobe/config.yaml`)<br></br>If you wont create this yourself, it will be autocreated.<br></br>You can use `probes.config` as a template.

```yaml
# Filepath for storing the probe status
store_file: /tmp/healthprobe/probes.store

# Polling interval in seconds
polling_interval: 1

# List of probes to be polled at interval time
probes:
    - name: TEST              # Name of the probe. No spaces, commas or semicolons allowed
      interval: 10            # Interval in seconds to trigger
      action: store           # Action to be taken when the probe is triggered. Current options: store, none
      reset_if: retrieved     # When to reset the timer. Defaults to 'continuously'. Current options: continuously, retrieved
```

3. Add the healthprobe background process to your shell startup script (e.g. `~/.bashrc`, `~/.zshrc`).

```bash
# Start the healthprobe background process within the same context
source <PATH_TO_REPOSITORY>/start.bash <PATH_TO_CONFIG_FILE>
```

If you wont specify the config file, the default one will be used.

4. Restart your shell or run the script manually.

```bash
exec zsh -l
```

5. Optionally: Continue with the spaceship plugin installation.


### Spaceship

Once the healthprobe background process is set up, you can add the healthprobe status to the spaceship prompt.

1. Make sure you have spaceship installed. (See their documentation)

2. Load the spaceship plugin in your `~/.zshrc` file.

```bash
# Load the spaceship plugin
source <PATH_TO_REPOSITORY>/spaceship/healthprobe.plugin.zsh
```

3. Make sure the plugin is loaded before the spaceship file.

Look for- or add the following line to your `~/.zshrc` file.

```bash
source "/opt/homebrew/opt/spaceship/spaceship.zsh"
```

For this step you have to rely on the Spaceship documentation.

4. Configure the spaceship prompt to include the healthprobe status.

Use the spaceship configuration file (see their documentation) and add `healthprobe` to the `SPACESHIP_PROMPT_ORDER` array.

For example:

```bash
SPACESHIP_PROMPT_ORDER=(
  time           # Time stamps section
  user           # Username section
  healthprobe    # Healthprobe section
  dir            # Current directory section
  ...            # --- Other sections
)
```

5. Add the desired probes to your status in the spaceship configuration file.

```bash
# Healthprobe configuration

# Mandatory
SPACESHIP_HEALTHPROBE_SHOW=true             
SPACESHIP_HEALTHPROBE_RETRIEVE="TEST"       # Or add multiple probes separated by a comma

# Optional
SPACESHIP_HEALTHPROBE_ASYNC=true
SPACESHIP_HEALTHPROBE_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"
SPACESHIP_HEALTHPROBE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"
SPACESHIP_HEALTHPROBE_SYMBOL="🔴 "
SPACESHIP_HEALTHPROBE_COLOR="red"
SPACESHIP_HEALTHPROBE_CONFIG_PATH="${HOME}/.config/healthprobe/config.yaml"
SPACESHIP_HEALTHPROBE_PID_PATH="/tmp/healthprobe/healthprobe.pid"
```

6. Restart your shell or run the script manually.

```bash
exec zsh -l
```

7. Use the plugin.

Whenever the probe appears in the status, you have to acknowledge it before it disappears until the next trigger.
Since the healthprobe background process is detached, the trigger will appear in statusses across all terminal instances.

```bash
hpack <PROBE_NAME>
```
