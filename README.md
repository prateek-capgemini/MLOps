# EC2 Management Repository

This repository contains scripts to manage EC2 instances using Terraform and a Python wrapper.

## Setup

1. Clone this repository.
2. Set up your AWS credentials in the environment variables or GitHub Secrets.
3. Update the `config.py` file with your configuration settings.

## Usage

1. Run the wrapper script by executing `python wrapper.py`.
2. Follow the prompts to choose instance type and versions of Python/Pytorch/Cuda.
3. If run within GitHub Actions, instance termination will be triggered automatically.

### GitHub Actions

The repository is configured with a GitHub Actions workflow that automates the EC2 management process.


