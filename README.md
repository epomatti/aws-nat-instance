# AWS NAT Instance

Debian NAT instance running on AWS.

<img src=".assets/aws-nat2.png" />

Copy the variables template:

```sh
cp config/template.tfvars .auto.tfvars
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
cat /proc/sys/net/ipv4/ip_forward
```

Now set `create_private_server = true` and apply again.

To test it, connect to the private server using Sessions Manager.

If you wish to enable VPC endpoints, set the variable:

```terraform
create_vpc_endpoints = true
```

To use another distribution like Ubuntu, change the variables:

```terraform
# NAT instance
instance_type = "t4g.nano"
userdata      = "ubuntu.sh"
ami           = "ami-05983a09f7dc1c18f"
```

Useful articles [here][1] and [here][2].

## Virtual Network

## VNS3

Another option is to use Cohesive Networks VNS3 NATe:

```sh
mkdir keys && ssh-keygen -f keys/vns3
```

> [!TIP]
> Always check for an updated AMI

Set the variable flag:

```terraform
create_cohesive_nat = true
```

Reference documentation for VNS3:

- [VNS3 NATe](https://docs.cohesive.net/docs/nate/)
- [AWS Marketplace VNS3 AMI](https://aws.amazon.com/marketplace/pp/prodview-beu27g23xt4ok)
- [Getting Started](https://docs.cohesive.net/tutorials/getting-started/)
- [Running in AWS](https://docs.cohesive.net/docs/cloud-setup/aws/)
- [AWS Specific Features](https://docs.cohesive.net/docs/vns3/aws-features/)

[1]: https://linuxhint.com/configure-nat-on-ubuntu/
[2]: https://linuxconfig.org/how-to-make-iptables-rules-persistent-after-reboot-on-linux
