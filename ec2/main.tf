#Create a private Key that can be used in my_key_pair
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Create a Key Pair
resource "aws_key_pair" "test_key_pair" {
  key_name = "test_key_pair"

  # Use the tls_private_key to create a public key on AWS
  public_key = tls_private_key.private_key.public_key_openssh

  # Create a "myKey.pem" to your computer
  provisioner "local-exec" {
    command = "echo '${tls_private_key.private_key.private_key_pem}' > ./test_key_pair.pem"
  }
}

#Using a Terraform data source to find my current IP address
data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

#Creating a Security Group with HTTP, HTTPS, and SSH access
#SSH access is for my current IP address only
resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH access from your current ip"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH Access from your local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role_for_SSM" {
  name = "ec2-role-for-SSM"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ec2_ssm_attachment" {
  name       = "ec2-ssm-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles      = ["${aws_iam_role.ec2_role_for_SSM.name}"]
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "example-profile"
  role = "${aws_iam_role.ec2_role_for_SSM.name}"
}

#AMI for Test Instance
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

#Test instance
resource "aws_instance" "test" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.test_key_pair.key_name
  associate_public_ip_address = true
  security_groups = [aws_security_group.ssh_access.name]
  iam_instance_profile = "${aws_iam_instance_profile.ec2_ssm_profile.name}"
  tags = {
    Name = "Test"
  }
  user_data= <<EOF
#!/bin/bash
# Update the package manager cache
yum update -y
# Install the SSM Agent
yum install -y amazon-ssm-agent
EOF
}