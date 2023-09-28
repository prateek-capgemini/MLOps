import torch

# Check if CUDA is available
print(">>> import torch")
print(">>> torch.cuda.is_available()")
print(torch.cuda.is_available())

# Get the number of available CUDA devices
print(">>> torch.cuda.device_count()")
print(torch.cuda.device_count())