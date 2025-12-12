variable "aws_region" {
  type    = string
  default = "eu-noth-1"
}

variable "ACCOUNT_ID" {
  type = string
}

variable "REGION" {
  type = string
}

variable "key_name" {
  description = "EC2 Key pair name for SSH access (must exist in AWS)."
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "image_repo" {
  type    = string
  description = "Docker image repository (e.g. user/strapi or 111.dkr.ecr.region.amazonaws.com/strapi)"
}

variable "image_tag" {
  type    = string
  description = "Docker image tag to deploy"
  default = "latest"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}





