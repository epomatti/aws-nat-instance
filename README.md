# AWS NAT Instance

Debian NAT instance running on AWS.

<img src=".assets/aws-nat2.png" />

Create the `.auto.tfvars` with the following:

```terraform
# NAT instance
instance_type = "t4g.nano"
userdata      = "debian.sh"
ami           = "ami-0c758b376a9cf7862"

# Server
create_private_server = true
create_vpc_endpoints  = false
```

Apply your infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

After creating the resources, confirm that the NAT instance has been set up correctly:

```sh
cloud-init status

ip link show
sysctl -ar ip_forward
```

Now set `create_private_server = true` and apply again.

To test it, connect to the private server using Sessions Manager.

If you wish to enable VPC endpoints, set the variable:

```terraform
create_vpc_endpoints = true
```

To use another distro like Ubuntu, change the variables:

```terraform
# NAT instance
instance_type = "t4g.nano"
userdata      = "ubuntu.sh"
ami           = "ami-05983a09f7dc1c18f"
```

Useful articles [here][1] and [here][2].


[1]: https://linuxhint.com/configure-nat-on-ubuntu/
[2]: https://linuxconfig.org/how-to-make-iptables-rules-persistent-after-reboot-on-linux
