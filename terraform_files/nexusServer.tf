variable "nexus_instance_type" {}
variable "nexus_script_path" {}

resource "aws_instance" "NexusServer" {
  ami                    = data.aws_ami.centos.id
  instance_type          = var.nexus_instance_type
  subnet_id              = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.nexus-SG.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.jenkins-key.key_name

  user_data = file(var.nexus_script_path)

  tags = {
    Name = "${var.env_prefix}-nexusServer"
  }
}

output "nexus_public_ip" {
  value = aws_instance.NexusServer.public_ip
}