#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y

apt install -y telnet
apt install -y postgresql postgresql-contrib
