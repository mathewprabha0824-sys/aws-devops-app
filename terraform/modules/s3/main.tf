
resource "aws_s3_bucket" "app_assets" {
  bucket = "my-app-assets-bucket-dev-matx"
  acl    = "private"
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "AppAssetsS3AccessPolicy"
  description = "IAM policy for accessing application assets in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_assets.arn,
          "${aws_s3_bucket.app_assets.arn}/*"
        ]
      }
    ]
  })
}

