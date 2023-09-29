locals {
  yaml_rg = yamldecode(file("config.yaml"))
}

resource "aws_instance" "ec2" {
  ami           = local.yaml_rg.Ami_Id
  instance_type = local.yaml_rg.Instance_Type
  key_name      = local.yaml_rg.KEY_NAME

  root_block_device {
    volume_size = 30 # in GB <<----- I increased this! prateek
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = data.aws_kms_key.customer_master_key.arn
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
    
 
    EOF

  tags = {
    Name = local.yaml_rg.Instance_Name
  }
  
  provisioner "local-exec" {
    command = "chmod +x ./userdata/post_reboot.sh"
  }

  provisioner "local-exec" {
    command = "./userdata/post_reboot.sh"
  }

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
