#!/bin/bash

# Set the PyTorch version as an environment variable
#export PYTHON_VERSION="${local.yaml_rg.Python}"

# Update package list and install necessary packages
echo "Updating package list and installing necessary packages..."
sudo apt-get update -y
sudo apt-get install -y alsa-utils
sudo apt install -y python3-pip
sudo apt-get install -y ubuntu-drivers-common

#########################################################

# install other import packages
sudo apt-get install g++ freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev

# first get the PPA repository driver
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update

# install nvidia driver with dependencies
sudo apt install libnvidia-common-470
sudo apt install libnvidia-gl-470
sudo apt install nvidia-driver-470

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt-get update

#########################################################

# List available Ubuntu drivers and install the recommended driver
echo "Listing available Ubuntu drivers and installing the recommended driver..."
sudo ubuntu-drivers list
sudo ubuntu-drivers autoinstall


# Reboot the system
echo "Rebooting the system..."
sudo reboot

sleep 120
