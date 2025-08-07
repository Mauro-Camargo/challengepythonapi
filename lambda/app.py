import json
import os
import uuid
import boto3
from datetime import datetime

# Initialize AWS clients
ec2_client = boto3.client('ec2')
dynamodb_resource = boto3.resource('dynamodb')

# Table name from environment variable
TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME', 'PythonVpcChallengeTable')
table = dynamodb_resource.Table(TABLE_NAME)

def lambda_handler(event, context):
    http_method = event.get('requestContext', {}).get('http', {}).get('method')
    path = event.get('requestContext', {}).get('http', {}).get('path')

    print(f"Received {http_method} request for path: {path}")
    print(f"Event: {json.dumps(event)}")

    if http_method == 'POST' and path == '/vpcs':
        return create_vpc_and_subnets(event)
    elif http_method == 'GET' and path == '/vpcs':
        return list_vpcs()
    else:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({"message": "Unsupported method or path"})
        }

def create_vpc_and_subnets(event):
    try:
        # 1. Create VPC
        vpc_response = ec2_client.create_vpc(CidrBlock='10.0.0.0/16')
        vpc_id = vpc_response['Vpc']['VpcId']

        # Add tags to the VPC
        ec2_client.create_tags(
            Resources=[vpc_id],
            Tags=[{'Key': 'Name', 'Value': f'challenge-vpc-{vpc_id}'}]
        )
        print(f"VPC created: {vpc_id}")

        # 2. Creating two subnets in different availability zones
        subnets_ids = []
        availability_zones = ec2_client.describe_availability_zones()['AvailabilityZones']
        
        az1 = availability_zones[0]['ZoneName'] if len(availability_zones) > 0 else 'us-east-1a'
        az2 = availability_zones[1]['ZoneName'] if len(availability_zones) > 1 else 'us-east-1b'

        subnet1_response = ec2_client.create_subnet(
            VpcId=vpc_id,
            CidrBlock='10.0.1.0/24',
            AvailabilityZone=az1
        )
        subnet1_id = subnet1_response['Subnet']['SubnetId']
        subnets_ids.append(subnet1_id)
        ec2_client.create_tags(
            Resources=[subnet1_id],
            Tags=[{'Key': 'Name', 'Value': f'challenge-subnet-1-{subnet1_id}'}]
        )
        print(f"Subnet 1 created: {subnet1_id} in {az1}")

        subnet2_response = ec2_client.create_subnet(
            VpcId=vpc_id,
            CidrBlock='10.0.2.0/24',
            AvailabilityZone=az2
        )
        subnet2_id = subnet2_response['Subnet']['SubnetId']
        subnets_ids.append(subnet2_id)
        ec2_client.create_tags(
            Resources=[subnet2_id],
            Tags=[{'Key': 'Name', 'Value': f'challenge-subnet-2-{subnet2_id}'}]
        )
        print(f"Subnet 2 created: {subnet2_id} in {az2}")

        # 3. Store VPC and subnets information in DynamoDB
        item_id = str(uuid.uuid4())
        timestamp = datetime.now().isoformat()

        item = {
            'id': item_id,
            'vpc_id': vpc_id,
            'subnets': subnets_ids,
            'created_at': timestamp,
            'status': 'active'
        }
        
        table.put_item(Item=item)
        print(f"Item saved to DynamoDB: {item_id}")

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                "message": "VPC and subnets created and saved successfully!",
                "vpc_id": vpc_id,
                "subnets": subnets_ids,
                "dynamodb_item_id": item_id
            })
        }

    except Exception as e:
        print(f"Error creating VPC/Subnets or saving to DynamoDB: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({"message": "Internal Server Error", "error": str(e)})
        }

def list_vpcs():
    try:
        response = table.scan()
        vpcs = response.get('Items', [])

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(vpcs)
        }
    except Exception as e:
        print(f"Error listing VPCs from DynamoDB: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({"message": "Internal Server Error", "error": str(e)})
        }
