resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenkins-key"
  public_key = file(var.PUB_KEY_PATH)
}