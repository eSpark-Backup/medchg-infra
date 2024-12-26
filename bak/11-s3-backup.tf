# Create the S3 Bucket
resource "aws_s3_bucket" "k8s-backup-231224" {
  bucket = "k8s-backup-231224" # Replace with a unique bucket name
  acl    = "private"
  tags = {
    Name        = "k8s-backup-231224"
    Environment = "Dev"
  }
}



# Create an IAM role for accessing the S3 bucket
resource "aws_iam_role" "k8s-s3-backup-access-role" {
  name = "k8s-s3-backup-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a policy to the IAM role to allow access to the S3 bucket
resource "aws_iam_policy" "k8s-s3-backup-access-policy" {
  name = "k8s-s3-backup-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.k8s-backup-231224.arn,
          "${aws_s3_bucket.k8s-backup-231224.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "k8s-s3-backup-access-attachment" {
  role       = aws_iam_role.k8s-s3-backup-access-role.name
  policy_arn = aws_iam_policy.k8s-s3-backup-access-policy.arn
}

# Output the bucket name
output "k8s-s3-backup" {
  value = aws_s3_bucket.k8s-s3-backup.bucket
}

# Output the role ARN
output "role_arn" {
  value = aws_iam_role.k8s-s3-backup-access-role.arn
}
