#!/bin/bash

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
