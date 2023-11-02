variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-1 = "ami-0fc5d935ebf8bc3bc"
    us-east-2 = "ami-0e83be366243f524a"
  }
}

variable "PRIV_KEY_PATH" {}

variable "PUB_KEY_PATH" {}

variable "USERNAME" {
  default = "ubuntu"
}

variable "my_ip" {}

variable "instance_count" {
  default = "1"
}

variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "avail_zone" {}

variable "env_prefix" {}



