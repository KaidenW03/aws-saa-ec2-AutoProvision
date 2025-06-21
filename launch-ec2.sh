#!/bin/bash

# Variables
INSTANCE_NAME="AutoProvisionedCLI"
AMI_ID="ami-0df7a207adb9748c7"  # Amazon Linux 2023 (ap-southeast-2)
INSTANCE_TYPE="t2.micro"
SECURITY_GROUP_NAME="ec2-cloudinit-sg"
KEY_NAME="ec2-cloudinit-key"
USER_DATA_FILE="cloud-init.sh"
IAM_INSTANCE_PROFILE="EC2CloudWatchRole"
REGION="ap-southeast-2"

# 1. Create key pair (skip if already created)
aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' \
  --output text > ${KEY_NAME}.pem

chmod 400 ${KEY_NAME}.pem

# 2. Create a security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
  --group-name $SECURITY_GROUP_NAME \
  --description "Allow HTTP and SSH" \
  --region $REGION \
  --query 'GroupId' --output text)

# 3. Authorize inbound traffic (HTTP and SSH)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region $REGION

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region $REGION

# 4. Launch the EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --iam-instance-profile Name=$IAM_INSTANCE_PROFILE \
  --user-data file://$USER_DATA_FILE \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --region $REGION \
  --query 'Instances[0].InstanceId' \
  --output text)

# 5. Wait for the instance to be running
echo "Waiting for instance to enter 'running' state..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# 6. Fetch and display public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --region $REGION \
  --output text)

echo "EC2 instance launched successfully!"
echo "Public IP: http://$PUBLIC_IP"
