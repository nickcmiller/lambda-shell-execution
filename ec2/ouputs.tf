#-- ec2/outputs.tf --

output "ec2_public_dns" {
  value = aws_instance.test.public_dns
}
