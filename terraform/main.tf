
# Get Default VPC and Subnets
# Get default VPC
data "aws_vpcs" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

locals {
  default_vpc_id = data.aws_vpcs.default.ids[0]
}

# Get default subnets
resource "aws_subnet" "public" {
  vpc_id            = local.default_vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

# Security Group
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow Strapi and SSH"
  vpc_id      = data.default_vpc_id.default.id

  ingress {
    description = "Allow Strapi"
    from_port   = 1337
    to_port     = 1337
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
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "strapi" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.tpl", {
    image_repo = var.image_repo
    image_tag  = var.image_tag
  })

  tags = {
    Name = "Strapi-Server"
  }
}

#############################################
# Output EC2 Public IP
#############################################
output "ec2_public_ip" {
  value = aws_instance.strapi.public_ip
}

