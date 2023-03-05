# TF-Seed

Mostly Reusable Terraform Modules ;-)

##  Why "Mostly Reusable" and This Repo? 

DevSeed, for better or worse, is an organization where developers will probably have to be competent in both 
CDK and Terraform given the rate of project and staffing changes.

Terraform's (TF) IAC perspective is "opinionated" and mostly a "flat" representation of the API (at least regarding AWS). 
Other IAC tools often give developers the ability to create their own organizational patterns.
While some of this is true for TF, its perspective avoids a lot of yak shaving about "best practices" 
by keeping things flat.

The perspective above is one reason why it's hard to create reusable DRY modules in TF and that's an okay thing. 
Sometimes it's useful, especially for core AWS constructs, to try and be DRY -- hence this repository that might never
be more than these two modules.

---

## How to Use This?

It's pretty simple. Let's say I need a common VPC setup with a public/private subnets and CIDRs. In a different repository 
we can reference this module like so:

```terraform
# file: vpc.tf
module "networking" {
  source               = "github.com/developmentseed/tf-seed/modules/networking"
  project_name         = "captainbezerko"
  env                  = "staging"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "us-west-2"
  availability_zones   = ["us-west-2a", "us-west-2b"]
  tags                 = {"rancho": "deluxe"}
}
```

In this repository if we look at the `./modules/networking/output.tf` variables then we can get a sense of what this module exports.
Binding other resources to these output variables creates the dependency graph that TF follows. 

For example, let's say I want to add some new ingress rules for the default security group that the `networking` module
created. I could extend the example above like below (note that the statement `module.networking.default_sg_id` binds
the `networking` module output variable to my new resource):

```terraform
module "networking" {
  source               = "github.com/developmentseed/tf-seed/modules/networking"
  project_name         = "captainbezerko"
  env                  = "staging"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "us-west-2"
  availability_zones   = ["us-west-2a", "us-west-2b"]
  tags                 = {"rancho": "deluxe"}
}

resource "aws_security_group_rule" "ecs_service_port_addon" {
  description = "opened for ECS service port"
  type        = "ingress"
  from_port   = var.service_port
  to_port     = var.service_port
  protocol    = "tcp"
  security_group_id        = module.networking.default_sg_id
  source_security_group_id = module.networking.default_sg_id

  lifecycle {
    # useful if 'name', 'name_prefix', 'description' are dynamic properties.
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_ingress_addon" {
  description = "Allow ESC to talk to RDS"
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  security_group_id        = module.networking.default_sg_id
  source_security_group_id = module.ecs_cluster.service_security_group_id

  lifecycle {
    # useful if 'name', 'name_prefix', 'description' are dynamic properties.
    create_before_destroy = true
  }
}
```

Then later on in my other repository I might need to add RDS to a specific subnet. And so I add it to the VPC private
subnet:

```terraform
resource "aws_db_subnet_group" "db" {
  name       = "tf-${var.project_name}-${var.env}-subnet-group"
  subnet_ids = module.networking.private_subnets_id
  tags = {
    Name = "tf-${var.project_name}-subnet-group"
  }
}
```


