#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

### Update ###
apt update && apt upgrade -y

# CloudWatch Agent
# region=us-east-2
# arch=arm64
# distro=ubuntu
# wget "https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/$distro/$arch/latest/amazon-cloudwatch-agent.deb"
# dpkg -i -E ./amazon-cloudwatch-agent.deb

ssmParameterName=AmazonCloudWatch-linux-terraform
# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c "ssm:$ssmParameterName"
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c "ssm:$ssmParameterName"

### NAT ###
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
sysctl -w net.ipv4.ip_forward=1

# Set the forwarding permanently
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

apt install -y iptables-persistent
iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
iptables-save  > /etc/iptables/rules.v4


### Ubuntu Pro USG ###
apt install -y ubuntu-advantage-tools
pro enable usg
apt install -y usg

### AWS CLI ###
snap install aws-cli --classic

### USG ###
usg_bucket=$(aws ssm get-parameter --name "usg-bucket" --query Parameter.Value --output text)
aws s3api get-object --bucket "$usg_bucket" --key tailor.xml tailor.xml

# TODO: Failing for a Minimal instance
usg fix --tailoring-file tailor.xml

### Clean Up ###
rm -r amazon-cloudwatch-agent.deb



reboot
