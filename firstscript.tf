resource "aws_instance" "web" {
  ami = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  key_name = "capstone-key"
  count = 3

  tags = {
    Name = "managed_none ${count.index}"
  } 
}