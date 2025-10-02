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
> Currently there might be [issues](https://discourse.ubuntu.com/t/cis-compliance-with-usg-for-ubuntu-24-04-lts) with 24.04 LTS.

```sh
# Ubuntu Pro Server 24.04 (Noble) TLS Arm64
aws ssm get-parameters --region us-east-2 \
   --names '/aws/service/canonical/ubuntu/pro-server/noble/stable/current/arm64/hvm/ebs-gp3/ami-id'

# Or use the Minimal release
# Was available only for Jammy and EBS GP2
aws ssm get-parameters --region us-east-2 \
   --names '/aws/service/canonical/ubuntu/pro-minimal/jammy/stable/current/arm64/hvm/ebs-gp2/ami-id'

# To search by path
aws ssm get-parameters-by-path  --region us-east-2 --path '/aws/service/canonical/ubuntu/pro-minimal/' --recursive --output text
```

Set the variable values:

```terraform
ami      = "ami-0ffa1a4298cabeb40"
userdata = "ubuntu-pro.sh"
```

Deploy the resources:

```sh
terraform init
terraform apply -auto-approve
```

If you're running a minimal instance, try and check if the packages are < 500;

```sh
dpkg -l | wc -l
```

The USG [installation](https://ubuntu.com/security/certifications/docs/disa-stig/installation) steps are already implemented in via cloud init.

Connect to the instance and confirm USG is enabled:

```sh
pro status --all
```

Generate the tailoring file:

> [!TIP]
> An example file is available in the `examples/` directory:

```sh
# Select depending on your requirements
sudo usg generate-tailoring cis_level1_server tailor.xml
sudo usg generate-tailoring cis_level2_server tailor.xml
```

The following rules must be disabled with `selected="false"` to keep NAT operational:

```xml
<!--3.3.1: Ensure ip forwarding is disabled (Automated)-->
<select idref="xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward" selected="false"/>
<select idref="xccdf_org.ssgproject.content_rule_sysctl_net_ipv6_conf_all_forwarding" selected="false"/>

<!--4.2.2: Ensure iptables-persistent is not installed with ufw (Automated)-->
<select idref="xccdf_org.ssgproject.content_rule_package_iptables-persistent_removed" selected="false"/>

<!--3.3.8: Ensure source routed packets are not accepted (Automated)-->
<select idref="xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_conf_default_accept_source_route" selected="false"/>
```

You may wish to disable AIDE to speed up the tests:

```xml
<!--6.3.1: Ensure AIDE is installed (Automated)-->
<select idref="xccdf_org.ssgproject.content_rule_aide_build_database" selected="false"/>
<select idref="xccdf_org.ssgproject.content_rule_package_aide_installed" selected="false"/>
<!--6.3.2: Ensure filesystem integrity is regularly checked (Automated)-->
<select idref="xccdf_org.ssgproject.content_rule_aide_periodic_checking_systemd_timer" selected="false"/>
```

Apply the fix with the tailored configuration:

```sh
sudo usg fix --tailoring-file tailor.xml
```

Double check the configuration:

```sh
# IP Forwarding should be enabled
sysctl -ar ip_forward
cat /proc/sys/net/ipv4/ip_forward

# Source routing
sysctl -a | grep source_route | grep ipv4
sysctl -a | grep source_route | grep ipv6

# UFW should be enabled
systemctl ufw status
```

Additional reference documentation:

- [What is masquerade in the context of iptables](https://askubuntu.com/questions/466445/what-is-masquerade-in-the-context-of-iptables)
- [Disable source routing](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-server_security-disable-source-routing#sect-Security_Guide-Server_Security-Disable-Source-Routing)

## Lambda

To test Lambda VNET integration:

```sh
sam build
sam local invoke HelloWorldFunction
```

Update the function code:

```sh
sam build
aws lambda update-function-code --function-name litware \
  --zip-file fileb://myFunction.zip
```

Invoke remotely:

```sh
sam remote invoke corp
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
