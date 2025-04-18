#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt install -y ubuntu-advantage-tools
sudo pro enable usg
sudo apt install -y usg
