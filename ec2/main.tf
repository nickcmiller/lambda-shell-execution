#Create a private Key that can be used in test_key_pair
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Create a Key Pair
resource "aws_key_pair" "test_key_pair" {
  key_name = "test_key_pair"

  # Use the tls_private_key to create a public key on AWS
  public_key = tls_private_key.private_key.public_key_openssh

  # Create a "test_key_pair.pem" to your Cloud 9 IDE
  #chmod 400 this key pair on your CLI and you can use it to access your Test instance
  provisioner "local-exec" {
    command = "echo '${tls_private_key.private_key.private_key_pem}' > ./test_key_pair.pem"
  }
}

#Creating a Security Group with SSH access
resource "aws_security_group" "ssh_http_access" {
  name        = "ssh_access"
  description = "Allow SSH and HTTP access"
  
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
  
  ingress {
    description = "HTTP Access from your local machine"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  security_groups = [aws_security_group.ssh_http_access.name]
  iam_instance_profile = var.iam_instance_profile
  tags = {
    Name = "Test"
  }
  user_data= <<EOF
#!/bin/bash
# Update the package manager cache
yum update -y
# Install the SSM Agent
yum install -y amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent
EOF
}