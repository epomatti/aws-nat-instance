#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

### Update ###
apt update && apt upgrade -y

# CloudWatch Agent
region=us-east-2
arch=arm64
distro=ubuntu
wget "https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/$distro/$arch/latest/amazon-cloudwatch-agent.deb"
dpkg -i -E ./amazon-cloudwatch-agent.deb

ssmParameterName=AmazonCloudWatch-linux-terraform
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c "ssm:$ssmParameterName"

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
apt install -y unzip zip
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


reboot
