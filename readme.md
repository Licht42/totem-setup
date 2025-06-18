<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/docs/images/TOTEM_logo_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="/docs/images/TOTEM_logo_bright.svg">
  <img alt="TOTEM logo font" src="/docs/images/TOTEM_logo_bright.svg">
</picture>

# ZMK CONFIG FOR THE TOTEM SPLIT KEYBOARD

[Here](https://github.com/GEIGEIGEIST/totem) you can find the hardware files and build guide.\
[Here](https://github.com/GEIGEIGEIST/qmk-config-totem) you can find the QMK config for the TOTEM.

TOTEM is a 38 key column-staggered split keyboard running [ZMK](https://zmk.dev/) or [QMK](https://docs.qmk.fm/). It's meant to be used with a SEEED XIAO BLE or RP2040.


![TOTEM layout](/docs/images/TOTEM_layout.svg)



## HOW TO USE

### GitHub Actions

- fork this repo
- `git clone` your repo, to create a local copy on your PC (you can use the [command line](https://www.atlassian.com/git/tutorials) or [github desktop](https://desktop.github.com/))
- adjust the totem.keymap file (find all the keycodes on [the zmk docs pages](https://zmk.dev/docs/codes/))
- `git push` your repo to your fork
- on the GitHub page of your fork navigate to "Actions"
- scroll down and unzip the `firmware.zip` archive that contains the latest firmware
- connect the left half of the TOTEM to your PC, press reset twice
- the keyboard should now appear as a mass storage device
- drag'n'drop the `totem_left-seeeduino_xiao_ble-zmk.uf2` file from the archive onto the storage device
- repeat this process with the right half and the `totem_right-seeeduino_xiao_ble-zmk.uf2` file.

### Build locally with `west.sh`

You can use the `west.sh` script to build the firmware locally. 

Running it initializes a ZMK environment in a container, which requires either `podman` or `docker` to be installed for it to work. `git` should also be installed, as cloning the ZMK git repo is required to configure a working ZMK environment.

```bash
# First, run the west.sh script
bash west.sh

# After finishing initializing, you get access to the command line of a new container
# Run the following commands to initialize the project and download dependencies :
west init -l app/ && west update && west zephyr-export

# Finally, to build the firmware for both halves of the keyboard, you can run the following commands :

# left part :
west build -s app -d /workspaces/build/left  -p -b 'seeeduino_xiao_ble' -- -DZMK_CONFIG=/workspaces/zmk-config/config -DSHIELD=totem_left

# right part :
west build -s app -d /workspaces/build/right -p -b 'seeeduino_xiao_ble' -- -DZMK_CONFIG=/workspaces/zmk-config/config -DSHIELD=totem_right

# The files generated can each be found in 'build/left|right/zephyr/zmk.uf2'.
```

