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
CUDA_VERSION=$(yq eval '.CUDA' ./config.yaml)

# Print the extracted values
echo "PyTorch Version: $PYTORCH_VERSION"
echo "Python Version: $PYTHON_VERSION"
echo "CUDA Version: $CUDA_VERSION"

###########################################################

 # installing CUDA-11.3

if [$CUDA_VERSION=="11.3"]; then
    echo "Installing CUDA: $CUDA_VERSION ....."
    sudo apt install cuda-11-3
else
    echo "Provided CUDA version not supported "
fi

# setup your paths
echo 'export PATH=/usr/local/cuda-11.3/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.3/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
sudo ldconfig
if [ -z "$CUDA_VERSION" ]; then
    echo "CUDA version not provided. Skipping installation."
else
    # install cuDNN v11.3
    
    CUDNN_TAR_FILE="cudnn-11.3-linux-x64-v8.2.1.32.tgz"
    wget https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.2.1.32/11.3_06072021/cudnn-11.3-linux-x64-v8.2.1.32.tgz
    tar -xzvf ${CUDNN_TAR_FILE}

    # copy the following files into the cuda toolkit directory.
    sudo cp -P cuda/include/cudnn.h /usr/local/cuda-11.3/include
    sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda-11.3/lib64/
    sudo chmod a+r /usr/local/cuda-11.3/lib64/libcudnn*
fi

# Finally, to verify the installation, check
nvidia-smi
nvcc -V

# install Pytorch
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

##########################################################


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
    if [ $PYTORCH_VERSION=="1.12" ]; then
        pip install "torch==$PYTORCH_VERSION+cu113" torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
    else
        echo " Provided PYTorch version not supported..."
    fi
    
    # Display the torch installed version
    echo "Installed torch version"
    pip show torch | grep Version
    python --version
    python3 --version

    # Run the test script
    echo "Running the torch validation script..."
    python3 ./userdata/torch_validation.py
fi
