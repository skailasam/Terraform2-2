terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  access_key = "" // add your own key valuse here
  secret_key = ""
}

module "S3" { 
    source = ".//modules/S3/"
    #bucket name should be unique
    bucket_name = "final-task-s3"       
}

module "vpc" {
  source = ".//modules/vpc/"
  vpc_name = "default-vpc"
}

# creat 2 application servers in AZ 1 = eu-west-1c
module "app-servers-az-1" {
  source = ".//modules/instance/"
  instance_type = "t2.micro"
  availability_zone = "eu-west-1c"
  instance_name_tag = "application-server-"
}

# creat 2 application servers in AZ 2 = eu-west-1b
module "app-servers-az-2" {
  source = ".//modules/instance/"

  instance_type = "t2.micro"
  availability_zone = "eu-west-1b"
  instance_name_tag = "application-server-"
}

# creat 2 web app servers in AZ 1 = eu-west-1c
module "webapp-server-az-1" {
  source = ".//modules/instance/"

  instance_type = "t2.micro"
  availability_zone = "eu-west-1c"
  instance_name_tag = "webapp-server-"
}

# creat 2 web app servers in AZ 2 = eu-west-1b
module "webapp-server-az-2" {
  source = ".//modules/instance/"

  instance_type = "t2.micro"
  availability_zone = "eu-west-1b"
  instance_name_tag = "webapp-server-"
}

# security group
data "aws_security_group" "default" {
  vpc_id = "${module.vpc.vpc_id}"
  name   = "default"
}

# aws subnet
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "${module.vpc.vpc_id}"
}

# creat internal elb
module "elb_internal" {
  source = ".//modules/ELB/"

  name = "internal-elb"

  subnets         = data.aws_subnet_ids.subnet_ids.ids
  security_groups = [data.aws_security_group.default.id]
  internal        = true

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = 8080
      instance_protocol = "http"
      lb_port           = 8080
      lb_protocol       = "http"
    },
  ]

 /* access_logs = {
    bucket = "final-task-s3"
  }*/
  # ELB attachments
  number_of_instances = 4
  instances = [element(module.app-servers-az-1.instance_id, 0), element(module.app-servers-az-1.instance_id, 1), element(module.app-servers-az-2.instance_id, 0), element(module.app-servers-az-2.instance_id, 1)]
}

module "elb_attachment_internal" {
  source = ".//modules/attachment_lb"

  create_attachment = true

  number_of_instances = 4

  elb       = "${module.elb_internal.elb_id}"
  instances = [element(module.app-servers-az-1.instance_id, 0), element(module.app-servers-az-1.instance_id, 1), element(module.app-servers-az-2.instance_id, 0), element(module.app-servers-az-2.instance_id, 1)]
}

# internet facing elb
module "elb_internet_facing" {
  source = ".//modules/ELB/"

  name = "elb-internet-facing"

  subnets         = data.aws_subnet_ids.subnet_ids.ids
  security_groups = [data.aws_security_group.default.id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = 8080
      instance_protocol = "http"
      lb_port           = 8080
      lb_protocol       = "http"
    },
  ]

 /* access_logs = {
    bucket = "final-task-s3"
  }*/
  # ELB attachments
  number_of_instances = 4
  instances = [element(module.webapp-server-az-1.instance_id, 0), element(module.webapp-server-az-1.instance_id, 1), element(module.webapp-server-az-2.instance_id, 0), element(module.webapp-server-az-2.instance_id, 1)]
}

module "elb_attachment_internet-facing" {
  source = ".//modules/attachment_lb"

  create_attachment = true

  number_of_instances = 4

  elb       = "${module.elb_internet_facing.elb_id}"
  instances = [element(module.webapp-server-az-1.instance_id, 0), element(module.webapp-server-az-1.instance_id, 1), element(module.webapp-server-az-2.instance_id, 0), element(module.webapp-server-az-2.instance_id, 1)]
}