# Terraform - consul - ECS - Docker
# Provision and deploy the Consul on AWS using Terraform and Docker.
- [Introduction](#Introduction)
- [Pre-requisites](#pre-requisites)
- [Installation and configuration](#Installation-and-configuration)
- [Install Consul registory in ECS](#Install Consul registory in ECS)

# Introduction
In this post, we will deploy a highly available three-node Consul cluster to AWS. We will use Terraform to provision a set of EC2 instances and accompanying infrastructure.
The instances will be built from a basic ubuntu 18.04 ami. We will install the docker and deploy the consul and open the respective ports.
We will deploy Docker containers to each EC2 host, containing an instance of Consul server.

Consul - We will achieve high availability (HA) by clustering three Consul server nodes across the three Elastic Cloud Compute (EC2) instances.
We use consul for service discovery in ECS which will be explained in the last part.

# Pre-requisites
Before we get started installing the Consul stack on AWS. 
* Ensure you install the latest version of [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) is installed
* Create the IAM access in AWS to provision the ec2 instance,vpc,subnet,internet gateway,security group,iam.

# Installation and configuration
Clone the project locally to your host.

The AWS will provision and those are added as a part of variables, if you wish to change please feel free to change in variable.tf alone.

In this project we used the following provision.
* EC2 AMI - ami-0dad20bd1b9c8c004 
* EC2 Instance Type - t2.micro
* Region - Singapore
* VPC - 11.0.0.0/16
* Subnet - 11.0.1.0/24,11.0.2.0/24,11.0.0.0/24
* Port Opened - 8300,8301,8302,8500,8600,22

# Steps to run the provisioning in terraform
1. Clone the repo
```
git clone https://github.com/ahamedyaserarafath/terraform_promethus.git
```
2. Terraform initialize a working directory 
```
terraform init
```
3. Terraform to create an execution plan
```
terraform plan
```
4. Terraform apply to provision in aws
```
terraform apply
```
Note: The above command will provision the ec2 instance and install the Consul

# Install Consul registory in ECS
Do create a ELB for those three consul server with 8500

1. Edit the ecs_registrator.sh and add the respective server ip or ELB, make sure ECS can communicate with the same.
```
CONSUL_IP=54.254.252.6
to
CONSUL_IP=<ELB/IP>
```
2. Run the below command where dockerfile exists(Here [gliderlabs/registrator](https://github.com/gliderlabs/registrator) is used)
```
docker build -t ecs_consul_registrator .
```
3. Push the ecs_consul_registrator to ECR, please follow the [AWS Documents](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_GetStarted.html) to push the docker image.

4. Create a task with ecs_consul_registrator Container and mount the below file for service discovery of ecs cluster.
```
Container Path    	Source Volume 	Read only
/tmp/docker.sock	  sourcedocker

Name - sourcedocker
Source Path -/var/run/docker.sock
```
Json parser for your reference
```
       ...
       "mountPoints": [
        {
          "readOnly": null,
          "containerPath": "/tmp/docker.sock",
          "sourceVolume": "sourcedocker"
        }
        ...
        "volumes": [
        {
          "name": "sourcedocker",
          "host": {
            "sourcePath": "/var/run/docker.sock"
        }
        ...

```
