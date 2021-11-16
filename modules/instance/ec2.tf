resource "aws_instance" "instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  count = 2    # Here we are creating identical 2 machines.

  user_data = <<-EOF
      echo "This server has been created on $(date), by Terraform" > /var/creation_time.txt
  EOF

  tags = {
    Name = format("%s%s", var.instance_name_tag , "${count.index}")
  }

}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}