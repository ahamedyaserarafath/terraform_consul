
#Singapore regions

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

variable "aws_availability_zone" {
  description = "AWS availabitiy zone to launch servers."
  default     = [ "ap-southeast-1a","ap-southeast-1b","ap-southeast-1c" ]
}

variable "aws_instance_type" {
  description = "AWS Instance type"
  default     = "t2.micro"
}

# variable "aws_instance_tags" {
#   type = "list"
#   default = ["consul_server_1", "consul_server_2","consul_server_3"]
# }

variable "aws_public_key_name" {
  default = "consul_aws_rsa"
}

# Ubuntu Server 18.04 LTS (HVM), SSD Volume Type
variable "aws_amis" {
  default = {
    ap-southeast-1 = "ami-0dad20bd1b9c8c004"
  }
}

variable "name" {
  description = "Infrastructure name"
  default = "Consul_Server"
}

variable "env" {
  description = "Environment"
  default = "Prod"
}

variable "consul_server_vpc_cidr" {
  description = "VPC CIDR"
  default = "11.0.0.0/16"
}

variable "consul_server_security_group_closed_port" {
  description = "Security group for internal communication"
  default = "8300,8301,8302"
}

variable "consul_server_security_group_open_port" {
  description = "Security group for external communication"
  default = "8500,8600,22"
}

variable "consul_server_security_group_protocol" {
  description = "Security group for external communication"
  default = ["tcp","udp"]
}
