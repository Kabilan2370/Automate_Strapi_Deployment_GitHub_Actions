
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
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [local.default_vpc_id]
  }
}

# Security Group
data "aws_security_groups" "strapi_sg" {
  filter {
    name   = "vpc-id"
    values = [local.default_vpc_id]
  }

  filter {
    name   = "group-name"
    values = ["default"]
  }
}



# EC2 Instance
resource "aws_instance" "strapi" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [data.aws_security_groups.strapi_sg.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.tpl", {
    image_repo = var.image_repo
    image_tag  = var.image_tag
  })

  tags = {
    Name = "Strapi-Server"
  }
}


# Output EC2 Public IP
output "ec2_public_ip" {
  value = aws_instance.strapi.public_ip
}

