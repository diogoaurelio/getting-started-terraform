
provider "aws" {
  region = var.aws_region
  version = "2.49"
}

provider "random" {
  version = "2.2"
}
