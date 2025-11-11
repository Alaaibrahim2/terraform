provider "aws" {
  region  = "us-east-1"
  profile = "dev"
}

# Security Group يسمح بالـ SSH فقط
resource "aws_security_group" "allow_ssh" {
  name   = "allow-ssh"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH from anywhere"
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
}

# ناخد الـ Default VPC
data "aws_vpc" "default" {
  default = true
}

# ناخد Subnets جوه Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# إنشاء الـ EC2
resource "aws_instance" "server" {
  ami                         = "ami-0cae6d6fe6048ca2c"
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "omar-ec2"
  }
}

output "public_ip" {
  value = aws_instance.server.public_ip
}
