resource "aws_ecr_repository" "k8s-services" {
  name                 = "k8s-services"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


# Create a policy to allow access to the ecr
resource "aws_iam_policy" "k8s-ecr-services-readonly-access-policy" {
  name = "k8s-ecr-services-readonly-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
            ],
            "Resource": "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "k8s-ecr-access-attachment" {
  role       = aws_iam_role.k8s-workers-role.name
  policy_arn = aws_iam_policy.k8s-ecr-services-readonly-access-policy.arn
}


