data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

output "aws_ami" {
  value = data.aws_ami.ubuntu.id
}

resource "aws_instance" "jenkinsServer" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.jenkins-SG.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.jenkins-key.key_name
  
  user_data = file(var.jenkins_script_path)
  
  tags = {
    Name = "${var.env_prefix}-jenkinsServer"
  }
}

output "ec2_public_ip" {
  value = aws_instance.jenkinsServer.public_ip
}