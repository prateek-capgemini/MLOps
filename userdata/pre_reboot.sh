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


# Install PyTorch version
echo "Installing PyTorch version $PYTORCH_VERSION"
pip install "torch==$PYTORCH_VERSION"

# Reboot the system
#echo "Rebooting the system..."
#sudo reboot

#sleep 120
#####################################################################################################

# Install yq if not already installed
if ! command -v yq &> /dev/null; then
    echo "yq is not installed. Installing..."
    sudo apt update
    sudo apt install yq -y
fi

# Extract specific values from the YAML file
PYTORCH_VERSION=$(yq eval '.Pytorch' ./config.yaml)
PYTHON_VERSION=$(yq eval '.Python' ./config.yaml)

# Print the extracted values
echo "PyTorch Version: $PYTORCH_VERSION"
echo "Python Version: $PYTHON_VERSION"

# Check if PyTorch version is provided
if [ -z "$PYTORCH_VERSION" ]; then
    echo "PyTorch version not provided. Skipping installation."
else
    # Check NVIDIA GPU information after reboot
    echo "Checking NVIDIA GPU information after reboot..."
    nvidia-smi

    # Install Python virtual environment
    echo "Installing Python virtual environment..."
    sudo apt install -y python3-venv
    python3 -m venv auto_env
    source auto_env/bin/activate
    echo "end of the pyton virtual environment..........................
    .....................................................
    .................................................."

    # Install PyTorch version
    echo "Installing PyTorch version $PYTORCH_VERSION"
    pip install "torch==$PYTORCH_VERSION"

    # Display the torch installed version
    echo "Installed torch version"
    pip show torch | grep Version
    python --version
    python3 --version

    # Run the test script
    echo "Running the torch validation script..."
    python3 ./userdata/torch_validation.py
fi