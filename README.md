# AWS NAT Instance

Ubuntu NAT instance running on AWS.

<img src=".assets/aws-nat.png" />

After creating the resources, confirm that the NAT instance has been set up correctly:

```sh
cloud-init status

ip link show
sysctl -ar ip_forward
```

To test it, connect to the private server using Sessions Manager.

If you wish to enable VPC endpoints, set the variable:

```terraform
create_vpc_endpoints = false
```
