resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cloudfront_access" {
  statement {
    sid = "AllowCloudFrontOriginAccessControl"
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.default.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_only" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.cloudfront_access.json
}
