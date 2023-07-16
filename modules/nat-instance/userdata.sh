#!/usr/bin/env bash
su ec2-user

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo apt update
sudo apt upgrade -y

# NAT - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
sudo iptables-save
