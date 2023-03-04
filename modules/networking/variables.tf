variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "project_name" {
  description = "The project"
}

variable "env" {
  description = "The environment"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Optional tags to add to resources"
}

variable "ingress_rules_for_vpc_default_sg" {
  #################################################
  # EXAMPLE
  #################################################
  #  [
  #    {
  #      primary_key       = "1"
  #      description       = ""
  #      protocol          = "tcp"
  #      from_port         = 5432
  #      to_port           = 5432
  #    },
  #    {
  #      primary_key       = "2"
  #      description       = ""
  #      protocol          = "tcp"
  #      from_port         = 5000
  #      to_port           = 5000
  #    },
  #  ]
  #
  type = list(object({
    primary_key        = string
    protocol           = string
    description        = string
    from_port          = number
    to_port            = number
  }))
  default = []
  description = "add ingress rules to default VPC security group"
}
