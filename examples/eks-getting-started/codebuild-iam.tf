# CodeBuild용 IAM 역할
resource "aws_iam_role" "codebuild_role" {
  name = "terraform-codebuild-rookies-final-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# CodeBuild 권한 정책 연결
resource "aws_iam_role_policy_attachment" "codebuild_role_AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_role_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_role_AWSCodeBuildAdminAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
  role       = aws_iam_role.codebuild_role.name
}
