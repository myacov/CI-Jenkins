variable "sonar_instance_type" {}
variable "sonar_script_path" {}

resource "aws_instance" "sonarServer" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.sonar_instance_type
  subnet_id              = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.sonar-SG.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.jenkins-key.key_name

  user_data = file(var.sonar_script_path)

  tags = {
    Name = "${var.env_prefix}-sonarServer"
  }
}

output "sonar_public_ip" {
  value = aws_instance.sonarServer.public_ip
}