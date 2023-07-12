#!/usr/bin/env bash
su ec2-user

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo apt update
sudo apt upgrade -y

sudo apt -y install telnet

# NAT - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
sudo sysctl -w net.ipv4.ip_forward=1
