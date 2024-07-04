output "public_ip0" {
  value = aws_instance.web[0].public_ip
}
output "public_ip1" {
  value = aws_instance.web[1].public_ip
}
output "public_ip2" {
  value = aws_instance.web[2].public_ip
}