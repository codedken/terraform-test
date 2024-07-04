resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id


  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_subnet" "my_subnet" {
  cidr_block        = var.subnet_cidr
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = var.az

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

resource "aws_security_group" "sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP, HTTPS, and SSH access to inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_network_interface" "net-inter" {
  security_groups = [aws_security_group.sg.id]
  private_ips     = ["10.0.0.50"]
  subnet_id       = aws_subnet.my_subnet.id
}

resource "aws_eip" "eip" {
  associate_with_private_ip = "10.0.0.50"
  domain                    = "vpc"
  network_interface         = aws_network_interface.net-inter.id
  depends_on                = [aws_security_group.sg, aws_instance.web]
}

resource "aws_instance" "web" {
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  availability_zone = var.az
  count             = 3


  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.net-inter.id
  }

  user_data = <<-EOF
              #!/bin/bash

              sudo apt update && sudo apt upgrade -y
              sudo apt install apache2
              sudo systemctl restart apache2
              EOF
  tags = {
    Name = "${var.project_name}-${count.index}"
  }
}
