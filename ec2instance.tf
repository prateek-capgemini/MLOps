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
    sudo apt-get install -y alsa-utils
    sudo apt install -y python3-pip
    sudo apt-get install -y ubuntu-drivers-common
    echo "Updating package list and installing necessary packages complete"

    # Extract specific values from the YAML file
    #PYTORCH_VERSION=$(yq eval '.Pytorch' ./config.yaml)
    #PYTHON_VERSION=$(yq eval '.Python' ./config.yaml)
    echo "Listing available Ubuntu drivers and installing the recommended driver..."
    sudo ubuntu-drivers list
    sudo ubuntu-drivers autoinstall
    echo "start installing yq"
    snap install yq
    ############################################################
    # Install PyTorch version
    echo "Installing PyTorch version 1.12"
    pip install "torch==1.12"
    echo "Installing Python virtual environment..."
    sudo apt install python3.10-venv -y
    sudo apt install -y python3-venv
    sudo python3 -m venv auto_env
    python3 -m venv auto_env
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

resource "aws_iam_policy" "example_policy" {
  name        = "example-policy"
  description = "An example IAM policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DetachNetworkInterface",
          "ec2:AttachNetworkInterface",
          "s3:GetObject",
          "s3:PutObject",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = [
          "ssm:CreateAssociation",
          "ssm:UpdateAssociationStatus",
          "ssm:CancelCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:GetCommandInvocation",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = [
          "cloudwatch:PutMetricData",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = [
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}

# Define an IAM role and attach the IAM policy to it
resource "aws_iam_role" "example_role" {
  name = "example-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
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
