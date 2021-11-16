variable "instance_name_tag" {
  type = string
  default = "ec2"
  description = "The Value of the Name Tag; default is 'ec2' "
}


variable "instance_type" {
    type = string
    default = "t2.micro"
    description = "The Instance Type To Be Created; Default is t2.micro"
}

variable "availability_zone" {
  type = string
  description = "The AZ to create the instance"
}



