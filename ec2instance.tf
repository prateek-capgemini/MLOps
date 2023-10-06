locals {
  yaml_rg = yamldecode(file("config.yaml"))
}

resource "aws_instance" "ec2" {
  ami           = local.yaml_rg.Ami_Id
  instance_type = local.yaml_rg.Instance_Type
  key_name      = local.yaml_rg.KEY_NAME

  root_block_device {
    volume_size = 30  # Increase the volume size to 50 GB (default is 8 GB)
    volume_type = "gp2"
  }

  user_data     = <<-EOF
    #!/bin/bash
    
    # Update package list and install necessary packages
    echo "Updating package list and installing necessary packages..."
    sudo apt-get update -y
    sudo apt install -y python3-pip 
    sudo apt install -y nvidia-cuda-toolkit
    sudo apt-get install -y ubuntu-drivers-common 
    sudo apt-get install -y alsa-utils
    sudo ubuntu-drivers list  
    sudo ubuntu-drivers autoinstall

    
    # List available Ubuntu drivers and install the recommended driver
    echo "Listing available Ubuntu drivers and installing the recommended driver..."
    sudo modprobe nvidia

    # Install yq if not already installed
    if ! command -v yq &> /dev/null; then
      echo "yq is not installed. Installing..."
      sudo apt update
      sudo snap install yq
      sudo apt update
    fi

    # Extract specific values from the YAML file
    PYTORCH_VERSION=2.0 #$(yq eval '.Pytorch' ./config.yaml)
    PYTHON_VERSION=3.10  #$(yq eval '.Python' ./config.yaml)
    CUDA_VERSION=11.7    #$(yq eval '.CUDA' ./config.yaml)

    # Print the extracted values
    echo "PyTorch Version: $PYTORCH_VERSION"
    echo "Python Version: $PYTHON_VERSION"
    echo "Cuda Version: $CUDA_VERSION"

    # Check if PyTorch version is provided
    if [ -z "$PYTORCH_VERSION" ]; then
      echo "PyTorch version not provided. Skipping installation."
    else
      # Check NVIDIA GPU information after reboot
      echo "Checking NVIDIA GPU information after reboot..."
      nvidia-smi

      # Install Python virtual environment
      echo "Installing Python virtual environment..."
      sudo apt install python3.10-venv -y
      sudo su
      sudo python3 -m venv /auto_env
      source /auto_env/bin/activate

      echo "Increasing Swap Space...."
      sudo fallocate -l 2G /swapfile
      sudo chmod 600 /swapfile
      sudo mkswap /swapfile
      sudo swapon /swapfile

      echo "end of the pyton virtual environment..........................
      ....................................................................
      ...................................................................>"

      # Check if the desired_version matches one of the specified versions
      if [ "$CUDA_VERSION" == "11.7" ] || [ "$CUDA_VERSION" == "11.6" ] || [ "$CUDA_VERSION" == "11.3" ] || [ "$CUDA_VERSION" == "10.2" ] || [ "$CUDA_VERSION" == "10.1" ] || [ "$CUDA_VERSION" == "10.0" ]; then
        echo "Installing CUDA version $CUDA_VERSION"
        # Depending on the version, install PyTorch using pip
        if [ "$CUDA_VERSION" == "11.7" ]; then
          pip install torch==2.0.0+cu117 torchvision==0.15.1+cu117 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu117
        elif [ "$CUDA_VERSION" == "11.6" ]; then
          pip install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116
        elif [ "$CUDA_VERSION" == "11.3" ]; then
          pip install torch==1.12.0+cu113 torchvision==0.13.0+cu113 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu113
        elif [ "$CUDA_VERSION" == "10.2" ]; then
          pip install torch==1.11.0+cu102 torchvision==0.12.0+cu102 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu102
        elif [ "$CUDA_VERSION" == "10.1" ]; then
          echo "PyTorch version 1.10 not support CUDA version 10.1, hence installing CUDA version 10.2 for stable env."
          pip install torch==1.10.0+cu102 torchvision==0.11.0+cu102 torchaudio==0.10.0 -f https://download.pytorch.org/whl/torch_stable.html
        elif [ "$CUDA_VERSION" == "10.0" ]; then
          echo "PyTorch version 1.9 not support CUDA version 10.0, hence installing CUDA version 10.2 for stable env."
          pip install torch==1.9.0+cu102 torchvision==0.10.0+cu102 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
        fi
    
        echo "PyTorch version $PYTORCH_VERSION is now installed."
      else
        echo "Unsupported PyTorch version: $PYTORCH_VERSION"
      fi    
    fi
    EOF

  tags = {
    Name = local.yaml_rg.Instance_Name
  }
  
  # provisioner "local-exec" {
  #   command = "chmod +x ./userdata/post_reboot.sh"
  # }

  # provisioner "local-exec" {
  #   command = "./userdata/post_reboot.sh"
  # }

  #for windows
  /*provisioner "local-exec" {
    command = ".\\userdata\\post_reboot.sh"
  }*/
}
# resource "null_resource" "terminate_instances" {
#    triggers = {
#      instance_ids = join(",", concat(aws_instance.cpu_instance.*.id, aws_instance.gpu_instance.*.id))
#    }
 
# provisioner "local-exec" {
#      command = "aws ec2 terminate-instances --instance-ids ${self.triggers.instance_ids}"
#    }
#  }
