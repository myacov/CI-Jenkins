resource "aws_iam_role" "jenkins_role" {
    name = "jenkins-ecr-ecs-role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com" # Use "ecs-tasks.amazonaws.com" if Jenkins is on ECS
        }
      },
    ]
  })
}


# Attach the AmazonEC2ContainerRegistryFullAccess policy to the role
resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Attach the AmazonECS_FullAccess policy to the role
resource "aws_iam_role_policy_attachment" "ecs_full_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# Create an instance profile for the role
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# Output the role name and ARN
output "jenkins_role_name" {
  value = aws_iam_role.jenkins_role.name
}

output "jenkins_role_arn" {
  value = aws_iam_role.jenkins_role.arn
}
