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
			"Effect": "Allow",
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
resource "aws_iam_role_policy_attachment" "k8s-ecr-workers-access-attachment" {
  role       = aws_iam_role.k8s-workers-role.name
  policy_arn = aws_iam_policy.k8s-ecr-services-readonly-access-policy.arn
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "k8s-ecr-master-access-attachment" {
  role       = aws_iam_role.k8s-master-role.name
  policy_arn = aws_iam_policy.k8s-ecr-services-readonly-access-policy.arn
}


# Create a policy to allow access to the ecr
resource "aws_iam_policy" "k8s-ecr-services-ci-access-policy" {
  name = "k8s-ecr-services-ci-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
			"Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",			
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:GetDownloadUrlForLayer",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
            ],
            "Resource": "*"
      }
    ]
  })
}


# IAM ecr user 
resource "aws_iam_user" "k8s-ci-bot" {
  name = "k8s-ci-bot"
}


resource "aws_iam_user_policy_attachment" "k8s-ci-bot-attachment" {
  user       = aws_iam_user.k8s-ci-bot.name
  policy_arn = aws_iam_policy.k8s-ecr-services-ci-access-policy.arn
}

# 
resource "aws_iam_access_key" "k8s-ci-bot-creds" {
  user = aws_iam_user.k8s-ci-bot.name
}

