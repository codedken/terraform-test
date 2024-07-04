output "public_ip" {
  value = aws_instance.web[count.index].public_ip
}