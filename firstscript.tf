resource "aws_vpc" "my_vpc"{
    cidr_block = var.vpc_cidr

    tags = {
        Name = "managed_vpc"
    }
}


resource "aws_instance" "web" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  count = 3

  tags = {
    Name = "${var.project_name}-${count.index}"
  } 
}