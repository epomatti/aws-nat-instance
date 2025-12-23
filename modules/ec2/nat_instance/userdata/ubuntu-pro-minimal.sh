#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

### Update ###
apt update && apt upgrade -y
apt install -y less iptables-persistent ubuntu-advantage-tools
snap install aws-cli --classic

### CloudWatch Agent ###
# Installation
PLATFORM=$(dpkg --print-architecture)
REGION=$(aws ssm get-parameter --name /ubuntu_pro/region --query Parameter.Value --output text)
FILENAME=amazon-cloudwatch-agent.deb
curl "https://amazoncloudwatch-agent-$REGION.s3.$REGION.amazonaws.com/ubuntu/$PLATFORM/latest/$FILENAME" -o $FILENAME
dpkg -i -E "./$FILENAME"
# Configuration
SSM_PARAMETER_NAME=AmazonCloudWatch-linux
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c "ssm:$SSM_PARAMETER_NAME"


### NAT ###
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
sysctl -w net.ipv4.ip_forward=1

# Set the forwarding permanently
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
iptables-save  > /etc/iptables/rules.v4


### Ubuntu Pro USG ###
# Install
pro enable usg

# USG
USG_BUCKET=$(aws ssm get-parameter --name "/ubuntu_pro/usg_bucket" --query Parameter.Value --output text)
aws s3api get-object --bucket "$USG_BUCKET" --key ubuntu2404_CIS_1.xml tailor.xml

# TODO: Failing for a Minimal instance
usg fix --tailoring-file tailor.xml

### Clean Up & Reboot###
rm -r amazon-cloudwatch-agent.deb
reboot
