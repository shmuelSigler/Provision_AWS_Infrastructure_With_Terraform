# Terraform Infrastructure for Interconnected EC2 Instances in Two AWS Regions
This Terraform code deploys a simple infrastructure in two different AWS regions that includes EC2 instances in VPCs and allows them to communicate with each other using AWS SSM for added security.

##  Overview
This Terraform infrastructure deploys the following components:

- Two separate Virtual Private Clouds (VPCs) in different AWS regions.
- VPC peering connection between the two VPCs.
- Two EC2 instances (one in each VPC).
- Security groups to allow ICMP (ping) traffic between the instances.
- AWS IAM roles and profiles to enable AWS SSM for secure access.

##  Key Features
This infrastructure focuses on security by:

- Implementing VPC peering for private communication.
- Restricting ICMP traffic to the instances via security groups.
- Enabling AWS SSM for secure access - instances can only be accessed via SSM, not publicly

## What is VPC peering

A VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses.

You can create a VPC peering connection between your own VPCs and the VPCs can be in different Regions (also known as an inter-Region VPC peering connection). Instances in either VPC can communicate with each other as if they are within the same network.

When establishing peering relationships between VPCs across different AWS Regions, resources in the VPCs (for example, EC2 instances) in different AWS Regions can communicate with each other using private IP addresses, without using a gateway, VPN connection, or network appliance. 

- The traffic remains in the private IP space
- Traffic always stays on the global AWS backbone
- Inter-Region VPC peering provides a simple and cost-effective way to share resources between regions
-  SSM Agent is preinstalled on AMI Amazon Linux 2023

![](https://docs.aws.amazon.com/images/vpc/latest/peering/images/peering-intro-diagram.png)

## Verifying Connectivity

Once the infrastructure is deployed, you can test the connectivity between the EC2 instances. 
Proof of connectivity:

**The private ip of EC2 instance in us-east-1 region: 10.0.1.53** 

![](https://github.com/shmuelSigler/Provision_AWS_Infrastructure_With_Terraform/blob/main/screenshot/private%20ip%20of%20east%20ec2%20instance.png?raw=true)


**The private ip of EC2 instance in us-west-1 region: 10.1.1.179**

![](https://github.com/shmuelSigler/Provision_AWS_Infrastructure_With_Terraform/blob/main/screenshot/private%20ip%20of%20west%20ec2%20instance.png?raw=true)

**Ping from EC2 instance in us-east-1 region to 10.1.1.179**

![](https://github.com/shmuelSigler/Provision_AWS_Infrastructure_With_Terraform/blob/main/screenshot/ping%20from%20east%20to%20west.png?raw=true)


**Ping from EC2 instance in us-west-1 region to 10.0.1.53**

![](https://github.com/shmuelSigler/Provision_AWS_Infrastructure_With_Terraform/blob/main/screenshot/ping%20from%20west%20to%20east.png?raw=true)

 ## Run Locally

Before deploying this infrastructure, you should have the following:

- AWS CLI configured with necessary access.
- Terraform installed on your local machine.
- AWS access and secret keys set as environment variables or in your AWS credentials file.


Clone the project

```bash
  git clone https://github.com/shmuelSigler/Provision_AWS_Infrastructure_With_Terraform.git
```

Go to the project directory

```bash
  cd Provision_AWS_Infrastructure_With_Terraform
```


Initialize Terraform  
```bash
  terraform init
```

Apply the Terraform configuration  
```bash
  terraform apply
```

## Documentation

[Amazon Machine Images (AMIs) with SSM Agent preinstalled ](https://docs.aws.amazon.com/systems-manager/latest/userguide/ami-preinstalled-agent.html): SSM Agent is preinstalled on some Amazon Machine Images (AMIs) provided by AWS.

[AmazonSSMManagedInstanceCore](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonSSMManagedInstanceCore.html): The policy for Amazon EC2 Role to enable AWS Systems Manager service core functionality.

[How to Attach an IAM Role to EC2 Instance using Terraform](https://cloudkatha.com/how-to-attach-an-iam-role-to-ec2-instance-using-terraform/)

[VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html): A VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses.

<a href="https://trackgit.com">
<img src="https://us-central1-trackgit-analytics.cloudfunctions.net/token/ping/loh31myzjf6ap595rril" alt="trackgit-views" />
</a>
