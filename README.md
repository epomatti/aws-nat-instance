# AWS NAT Instance

Debian NAT instance running on AWS.

<img src=".assets/aws-nat2.png" />

Copy the variables template:

```sh
cp config/template.tfvars .auto.tfvars
```

Create the optional key for NATe:

```sh
mkdir keys && ssh-keygen -f keys/vns3
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
instance_type = "t4g.micro"
userdata      = "ubuntu.sh"
ami           = "ami-05983a09f7dc1c18f"
```

Useful articles [here][1] and [here][2].

## VPC Block Private Access

For extra security controls, configure the VPC section of parameters:

> [!IMPORTANT]
> This feature only fully integrates with NAT Gateway, such as for `allow-egress`. When using NAT instances, `allow-bidirectional` is required.

```terraform
apply_vpc_bpa                                      = false
create_nat_subnet_exclusion                        = true
create_private_subnet_exclusion                    = true
vpc_internet_gateway_block_mode                    = "block-bidirectional" # "block-bidirectional", "block-ingress", "off"
vpc_nat_subnet_internet_gateway_exclusion_mode     = "allow-bidirectional" # "allow-bidirectional", "allow-egress"
vpc_private_subnet_internet_gateway_exclusion_mode = "allow-bidirectional" # "allow-bidirectional", "allow-egress"
```

## Ubuntu Pro USG

When applying Ubuntu Pro hardening with USG, additional configuration is required. The CIS benchmark rules will constraint the NAT instance capabilities.

To setup the environment, first configure the required variables.

Find the [latest](https://documentation.ubuntu.com/aws/en/latest/aws-how-to/instances/find-ubuntu-images/) Ubuntu Pro AMI:

> [!TIP]
> Right now, USG is not yet available for 24.04

```sh
aws ssm get-parameters --names \
   '/aws/service/canonical/ubuntu/pro-server/jammy/stable/current/arm64/hvm/ebs-gp3/ami-id'
```

Set the variable values:

```terraform
ami      = "ami-06f50fcd71f272ce1"
userdata = "ubuntu-pro.sh"
```

Deploy the resources:

```sh
terraform init
terraform apply -auto-approve
```

Connect to the instance and confirm that an Ubuntu Pro AMI has been selected:

```sh
pro status --all
```

Follow the [installation](https://ubuntu.com/security/certifications/docs/disa-stig/installation) process:

```sh
sudo apt update
sudo apt install -y ubuntu-advantage-tools
sudo pro enable usg
sudo apt install -y usg
```

Generate the tailoring file:

> [!TIP]
> An example file is available in the `examples/` directory:

```sh
sudo usg generate-tailoring cis_level1_server tailor.xml
```

The following rules must be disabled with `selected = false`

- 3.2.2 Ensure IP forwarding is disabled (Automated)

```sh
sudo usg fix --tailoring-file tailor.xml
```

## VNS3

Another option is to use Cohesive Networks VNS3 NATe:

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
