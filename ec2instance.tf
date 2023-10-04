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
    
    sudo su
    # Update package list and install necessary packages
    echo "Updating package list and installing necessary packages..."
    sudo apt-get update -y
    sudo apt install -y python3-pip 
    sudo apt install -y nvidia-cuda-toolkit
    sudo apt-get install -y ubuntu-drivers-common 
    sudo apt-get install -y alsa-utils
    sudo ubuntu-drivers list  
    sudo ubuntu-drivers autoinstall
    ##################################################################################
    echo "Updating package list and installing necessary packages..."
    sudo apt-get update -y

    ############################################################
    # Install PyTorch version
    echo "Installing PyTorch version 1.12"
    pip install "torch==1.12"
    echo "Installing Python virtual environment..."
    sudo apt install python3.10-venv -y
    sudo apt install -y python3-venv
    sudo python3 -m venv /auto_env
    python3 -m venv /auto_env
    source auto_env/bin/activate
    echo "end of the pyton virtual environment..........................
    .....................................................
    .................................................."

    # Install PyTorch version
    echo "Installing PyTorch version 1.12"
    pip install "torch==1.12"

    deactivate
    
    # List available Ubuntu drivers and install the recommended driver
    echo "Listing available Ubuntu drivers and installing the recommended driver..."
    sudo modprobe nvidia
    
 
    EOF

  tags = {
    Name = local.yaml_rg.Instance_Name
  }
  
  #provisioner "local-exec" {
  #  command = "chmod +x ./userdata/post_reboot.sh"
  #}

  #provisioner "local-exec" {
  #  command = "./userdata/post_reboot.sh"
  #}

  #for windows
  /*provisioner "local-exec" {
    command = ".\\userdata\\post_reboot.sh"
  }*/
}



# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "example_attachment" {
  policy_arn = aws_iam_policy.example_policy.arn
  roles      = [aws_iam_role.example_role.name]
}
# resource "null_resource" "terminate_instances" {
#    triggers = {
#      instance_ids = join(",", concat(aws_instance.cpu_instance.*.id, aws_instance.gpu_instance.*.id))
#    }
 
# provisioner "local-exec" {
#      command = "aws ec2 terminate-instances --instance-ids ${self.triggers.instance_ids}"
#    }
#  }
