
output "network_cidr" {
  value = "Network CIDR is ${local.network}"
}

output "vpc_details" {
  value = "VPC id ${data.aws_vpc.example.id}, CIDR block ${data.aws_vpc.example.cidr_block}, ARN: ${data.aws_vpc.example.arn}"
}

output "random" {
  value = "Your random characters generated were: ${random_string.random.result}"
}

output "example_iterarion_over_list" {
  value = var.some_list[*]
}

output "example_iteration_over_map_keys" {
  value = keys(var.some_map)[*]
}

output "example_iteration_over_map_values" {
  value = values(var.some_map)[*]
}

output "module_bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "module_bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
