
variable "aws_region" {
  type        = string
  description = "Default AWS region"
  default     = "eu-west-1"
}

variable "vpc_id" {
  type        = string
  description = "The VPC id of some VPC"
  default     = "vpc-f0ce1a96"
}

variable "some_list" {
  type        = list(string)
  description = "Some list for example purposes"
  default     = [1, 2, 3, 4, 5]
}

variable "some_map" {
  type = map(string)
  description = "Some map for example purposes"
  default = { Name="some", Environment = "prod" }
}

