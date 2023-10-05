#!/bin/bash

# Set the PyTorch version as an environment variable
#export PYTHON_VERSION="${local.yaml_rg.Python}"

# Update package list and install necessary packages
echo "Updating package list and installing necessary packages..."
sudo apt-get update -y
sudo apt-get install -y alsa-utils
sudo apt install -y python3-pip
sudo apt-get install -y ubuntu-drivers-common

# List available Ubuntu drivers and install the recommended driver
echo "Listing available Ubuntu drivers and installing the recommended driver..."
sudo ubuntu-drivers list
sudo ubuntu-drivers autoinstall


# Reboot the system
echo "Rebooting the system..."
sudo reboot

sleep 120