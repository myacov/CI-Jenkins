variable "jenkins_instance_type" {}
variable "jenkins_script_path" {}

resource "aws_instance" "jenkinsServer" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.jenkins_instance_type
  iam_instance_profile   = aws_iam_instance_profile.jenkins_instance_profile.name
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

output "jenkins_public_ip" {
  value = aws_instance.jenkinsServer.public_ip
}