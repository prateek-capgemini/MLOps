import logging
from PIL import Image
import yaml
import sys
import datetime

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("ec2_manager")


def read_yaml():
    with open("config.yaml", "r") as file:
        data = yaml.safe_load(file)
        return data
    
# def get_estimated_cost(instance_id, start_time, end_time):
#     client = boto3.client('ce', region_name=region)
#     response = client.get_cost_and_usage(
#         TimePeriod={
#             'Start': start_time.strftime('%Y-%m-%d'),
#             'End': end_time.strftime('%Y-%m-%d')
#         },
#         Granularity='MONTHLY',
#         Metrics=['UnblendedCost'],
#         Filter={
#             'Dimensions': {
#                 'InstanceId': [instance_id]
#             }
#         }
#     )
#     results = response['ResultsByTime']
#     if results:
#         cost = float(results[0]['Total']['UnblendedCost']['Amount'])
#         currency = results[0]['Total']['UnblendedCost']['Unit']
#         return cost, currency
#     else:
#         return None, None

def check_request_type(yaml_data):
    logger.info(f"Received YAML data: {yaml_data}")
    if yaml_data["Action"] == "CREATE":
        logger.info("Received 'CREATE' action. Invoking validate_create_instance.")
        validate_create_instance(yaml_data)
    else:
        logger.info("Received TERMINATE action. Invoking validate_terminate_instance.")
        validate_terminate_instance(yaml_data)

def validate_create_instance(yaml_data):
    # Check PyTorch version
    pytorch_version = yaml_data.get("Pytorch")
    if pytorch_version:
        valid_pytorch_versions = ["2.0", "1.13.0", "1.12", "1.11", "1.10", "1.9"]
        if pytorch_version not in valid_pytorch_versions:
            logger.error("Invalid PyTorch version provided. Please refer to the compatibility matrix below:")
            img = Image.open("versions.jpg")
            img.show()
            return
    else:
        logger.info("PyTorch version not provided. Proceeding without PyTorch installation.")

    # Check CUDA version
    cuda_version = yaml_data.get("CUDA")
    if cuda_version:
        valid_cuda_versions = ["11.7", "11.6", "11.3", "10.2", "10.1", "10.0"]
        if cuda_version not in valid_cuda_versions:
            logger.error("Invalid CUDA version provided. Please refer to the compatibility matrix below:")
            img = Image.open("versions.jpg")
            img.show()
            return
    else:
        logger.info("CUDA version not provided. Proceeding without CUDA installation.")

    # Print other relevant information
    print(yaml_data["Action"])
    logger.info(f"Action: {yaml_data['Action']}")
    logger.info(f"Instance Name: {yaml_data['Instance_Name']}")
    logger.info(f"Instance ID: {yaml_data['Instance_id']}")

# def validate_create_instance(yaml_data):
#     # Valid versions for validation
#     valid_pytorch_versions = ["2.0", "1.13.0", "1.12", "1.11", "1.10", "1.9"]
#     valid_python_versions = [f"{major}.{minor}" for major in range(3, 4) for minor in range(6, 11)]
#     valid_cuda_versions = ["11.7", "11.6", "11.3", "10.2", "10.1", "10.0"]

#     # Check if provided versions are valid
#     if yaml_data["Pytorch"] not in valid_pytorch_versions or \
#        yaml_data["Python"] not in valid_python_versions or \
#        yaml_data["CUDA"] not in valid_cuda_versions:
#         logger.error("Incompatible versions detected. Please refer to the compatibility matrix below:")
#         img = Image.open("versions.jpg")
#         img.show()
#         return
#     print(yaml_data["Action"])

#     logger.info(f"Action: {yaml_data['Action']}")
#     logger.info(f"Instance Name: {yaml_data['Instance_Name']}")
#     logger.info(f"Instance ID: {yaml_data['Instance_id']}")

def validate_terminate_instance(yaml_data):
    logger.info(f"Action: {yaml_data['Action']}")

    instance_id = yaml_data.get('Instance_id')
    instance_name = yaml_data.get('Instance_Name')

    if instance_id and instance_id != "None":
        logger.info(f"Instance Name: {instance_name}")
        logger.info(f"Instance ID: {instance_id}")
    else:
        logger.error("Invalid or missing instance ID. For terminating an instance, instance_id and instance name should not be None. It should be a proper instance ID. You can get it from the AWS EC2 console.")
        sys.exit(1)

    if instance_name and instance_name != "None":
        logger.info(f"Instance Name: {instance_name}")
    else:
        logger.error("Invalid or missing instance_id and instance_name. For terminating an instance, instance_id and instance name should not be None. It should be a proper instance ID. You can get it from the AWS EC2 console.")
        sys.exit(1)

    # # Fetch estimated cost for the instance
    # start_time = datetime.datetime(2023, 9, 1)  # Adjust start and end times accordingly
    # end_time = datetime.datetime(2023, 9, 30)
    # cost, currency = get_estimated_cost(instance_id, start_time, end_time)

    # if cost is not None and currency is not None:
    #     print(f"Estimated cost for the instance from {start_time} to {end_time}: {cost} {currency}")
    # else:
    #     print("Failed to fetch estimated cost.")
        
        return    

    print(yaml_data["Action"])


# def validate_terminate_instance(yaml_data):
#     logger.info(f"Action: {yaml_data['Action']}")
    
#     # Check if the instance ID is provided and not "None"
#     if yaml_data["Instance_id"] and yaml_data["Instance_Name"] != "None":
#         logger.info(f"Instance Name: {yaml_data['Instance_Name']}")
#         logger.info(f"Instance ID: {yaml_data['Instance_id']}")
#     else:
#         logger.info("For terminating an instance, instance_id and instance name should not be None. It should be a proper instance ID. You can get it from the AWS EC2 console.")
#         sys.exit(1)
#         return
        
#     print(yaml_data["Action", "Instance_id", "Instance_Name"])


yaml_data = read_yaml()

check_request_type(yaml_data)
