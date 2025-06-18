#!/bin/bash

config_dir=$(realpath $(dirname -- "$0";))

# clone zmk (if not done already)
if [ -d "$config_dir/zmk" ]; then
  echo "✅ ZMK Directory already exists"
else
  echo -ne "⏳ Cloning ZMK git repo...\r"
  git clone https://github.com/zmkfirmware/zmk.git "$config_dir/zmk"
  echo -ne "✅ Cloning ZMK git repo... Done !\n"
fi

# manage volumes
echo -ne "⏳ Creating new podman volume...\r"
podman volume rm --force zmk-config 2&> /dev/null
podman volume create --driver local -o o=bind -o type=none -o device="$config_dir/" zmk-config 2&> /dev/null
echo -ne "✅ Creating new podman volume... Done !\n"

# build container
echo -ne "⏳ Building podman image...\r"
podman build -t zmk-west -f "$config_dir/zmk/.devcontainer/Dockerfile" 2&> /dev/null
echo -ne "✅ Building podman image... Done !\n"

echo "ℹ️  Run the following commands if running this script for the first time :"
echo "west init -l app/ && west update && west zephyr-export"
echo ""
echo "ℹ️  To build the firmware for both halves of the keyboard :"
echo "west build -s app -d /workspaces/build/left  -p -b 'seeeduino_xiao_ble' -- -DZMK_CONFIG=/workspaces/zmk-config/config -DSHIELD=totem_left"
echo "west build -s app -d /workspaces/build/right -p -b 'seeeduino_xiao_ble' -- -DZMK_CONFIG=/workspaces/zmk-config/config -DSHIELD=totem_right"
echo ""
echo "ℹ️  The files generated can be found in 'build/left|right/zephyr/zmk.uf2'."

mkdir -p "$config_dir/build"

# run the container
podman run -it --rm \
  --security-opt label=disable \
  --workdir /workspaces/zmk \
  -v "$config_dir/zmk:/workspaces/zmk" \
  -v "$config_dir:/workspaces/zmk-config" \
  -v "$config_dir/build:/workspaces/build" \
  -p 3000:3000 \
  zmk-west /bin/bash
