# -- root/ouputs.tf -- 

output "test_instance_connection_script" {
  value = "ssh -i 'test_key_pair.pem' ec2-user@${module.ec2.ec2_public_dns}"
}
