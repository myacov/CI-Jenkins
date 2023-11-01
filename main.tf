provider "aws" {
  region = var.AWS_REGION
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id     = aws_vpc.dev-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}