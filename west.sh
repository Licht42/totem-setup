#!/bin/bash

config_dir=$(realpath $(dirname -- "$0";))
container_mgmt=""

# choose the container command (docker or podman), depending on what's currently installed
if which podman &> /dev/null; then
  container_mgmt="podman"
else
  if which docker &> /dev/null; then
    container_mgmt="docker"
  else
    echo "❌ This script requires either podman or docker to be installed. Please install either, then retry."
    exit 1
  fi
fi

echo "✅ Found $container_mgmt executable, continuing..."

# clone zmk (if not done already)
if [ -d "$config_dir/zmk" ]; then
  echo "✅ ZMK Directory already exists"
else
  echo -ne "⏳ Cloning ZMK git repo...\r"
  git clone https://github.com/zmkfirmware/zmk.git "$config_dir/zmk"
  echo -ne "✅ Cloning ZMK git repo... Done !\n"
fi

# manage volumes
echo -ne "⏳ Creating new $container_mgmt volume...\r"
$container_mgmt volume rm --force zmk-config 2&> /dev/null
$container_mgmt volume create --driver local -o o=bind -o type=none -o device="$config_dir/" zmk-config 2&> /dev/null
echo -ne "✅ Creating new $container_mgmt volume... Done !\n"

# build container
echo -ne "⏳ Building $container_mgmt image...\r"
$container_mgmt build -t zmk-west -f "$config_dir/zmk/.devcontainer/Dockerfile" 2&> /dev/null
echo -ne "✅ Building $container_mgmt image... Done !\n"

echo "ℹ️  Run the following commands if running this script for the first time :"
echo -e "west init -l app/ && west update && west zephyr-export\n"

echo -e "ℹ️ To build the firmware for both halves of the keyboard :\n"
echo -e "west build -s app -d /workspaces/build/left -p -b 'seeeduino_xiao_ble' -- -DZMK_CONFIG=/workspaces/zmk-config/config -DSHIELD=totem_left\n"
echo -e "west build -s app -d /workspaces/build/right -p -b 'seeeduino_xiao_ble' -- -DZMK_CONFIG=/workspaces/zmk-config/config -DSHIELD=totem_right\n"

echo "ℹ️ The files generated can be found in 'build/left|right/zephyr/zmk.uf2'."

mkdir -p "$config_dir/build"

# run the container
$container_mgmt run -it --rm \
  --security-opt label=disable \
  --workdir /workspaces/zmk \
  -v "$config_dir/zmk:/workspaces/zmk" \
  -v "$config_dir:/workspaces/zmk-config" \
  -v "$config_dir/build:/workspaces/build" \
  -p 3000:3000 \
  zmk-west /bin/bash
