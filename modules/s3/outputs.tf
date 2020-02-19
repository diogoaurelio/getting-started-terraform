

output "bucket_name" {
  value = data.aws_s3_bucket.selected.bucket
}

output "bucket_arn" {
  value = data.aws_s3_bucket.selected.arn
}
