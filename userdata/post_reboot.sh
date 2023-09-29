#!/bin/bash

sudo su ##################prateek####################

# Install yq if not already installed
if ! command -v yq &> /dev/null; then
    echo "yq is not installed. Installing..."
    sudo apt update
    sudo apt upgrade               #prateek
    sudo snap install yq           # sudo snap install yq #prateek
fi

# Extract specific values from the YAML file
#PYTORCH_VERSION=$(yq eval '.Pytorch' ./config.yaml)
PYTHON_VERSION=$(yq eval '.Python' ./config.yaml)
CUDA_VERSION=$(yq eval '.CUDA' ./config.yaml)

# Print the extracted values
#echo "PyTorch Version: $PYTORCH_VERSION"
echo "Python Version: $PYTHON_VERSION"

# Check if PyTorch version is provided
if [ -z "$CUDA_VERSION" ]; then
    echo "CUDA version not provided. Skipping installation."
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
    #echo "Installing PyTorch version $PYTORCH_VERSION"
    echo "Installing PyTorch for CUDA version $CUDA_VERSION"
    if ["$CUDA_VERSION" -eq "11.7"]; then
        pip install torch==2.0.0+cu117 torchvision==0.15.1+cu117 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu117
    elif ["$CUDA_VERSION" -eq "11.8"]; then
        pip install torch==2.0.0+cu118 torchvision==0.15.1+cu118 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu118
    else
        echo "Specified CUDA Version not supported..."
    fi
    #pip3 install "torch $PYTORCH_VERSION"                   #pip3 added #prateek

    # Display the torch installed version
    echo "Installed torch version"
    pip show torch | grep Version
    python --version
    python3 --version

    # Run the test script
    echo "Running the torch validation script..."
    python3 ./userdata/torch_validation.py
fi