output "bucket_name" {
  value = aws_s3_bucket.default.bucket
}

output "api_repository_name" {
  value = aws_ecr_repository.api_repository.name
}

output "batch_repository_name" {
  value = aws_ecr_repository.batch_repository.name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
