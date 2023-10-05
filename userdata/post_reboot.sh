#!/bin/bash

# Install yq if not already installed
if ! command -v yq &> /dev/null; then
    echo "yq is not installed. Installing..."
    sudo apt update
    sudo snap install yq
fi

# Extract specific values from the YAML file
PYTORCH_VERSION=$(yq eval '.Pytorch' ./config.yaml)
PYTHON_VERSION=$(yq eval '.Python' ./config.yaml)
CUDA_VERSION=$(yq eval '.CUDA' ./config.yaml)

# Print the extracted values
echo "PyTorch Version: $PYTORCH_VERSION"
echo "Python Version: $PYTHON_VERSION"
echo "CUDA Version: $CUDA_VERSION"



# Check if PyTorch version is provided
if [ -z "$PYTORCH_VERSION" ]; then
    echo "PyTorch version not provided. Skipping installation."
else
    # Check NVIDIA GPU information after reboot
    echo "Checking NVIDIA GPU information after reboot..."
    nvidia-smi

    echo "Increasing Swap Space...."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    echo "Building pyton virtual environment...."
    sudo python3 -m venv /auto_env
    cd /auto_env/bin/
    source activate
    echo "end of the pyton virtual environment..........................
    .....................................................
    .................................................."

    # Install PyTorch version
    sudo su
    if [ $CUDA_VERSION=="11.7" ]; then
        echo "Installing PYTorch version : 2.0"
        pip install torch==2.0.0+cu117 torchvision==0.15.1+cu117 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu117
    elif [ $CUDA_VERSION=="11.6" ]; then
        echo "Installing PYTorch version : 1.13"
        pip install torch==1.13.0+cu116 torchvision==0.14.0+cu116 torchaudio==0.13.0 --extra-index-url https://download.pytorch.org/whl/cu116
    elif [ $CUDA_VERSION=="11.3" ]; then
        echo "Installing PYTorch version : 1.12"
        pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
    elif [ $CUDA_VERSION=="10.2" ]; then
        echo "Installing PYTorch version : 1.11"
        pip install torch==1.11.0+cu102 torchvision==0.12.0+cu102 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu102
    elif [ $CUDA_VERSION=="10.1" ]; then
        echo "Installing PYTorch version : 1.10"
        pip install torch==1.10.0+cu101 torchvision==1.10.0+cu101 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu101
    elif [ $CUDA_VERSION=="10.0" ]; then
        echo "Installing PYTorch version : 1.9"
        pip install torch==1.9.0+cu102 torchvision==0.10.0+cu102 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
    else
        echo "CUDA Version undefined, Skipping PYTorch installaton..."
    fi
    # CUDA 11.3
    
    #pip install "torch==1.12"

    deactivate

    # Install PyTorch version
    #echo "Installing PyTorch version $PYTORCH_VERSION"
    #pip install "torch==$PYTORCH_VERSION"
    
    # Display the torch installed version
    echo "Installed torch version"
    pip show torch | grep Version
    python --version
    python3 --version

    # Run the test script
    echo "Running the torch validation script..."
    python3 ./userdata/torch_validation.py
fi
