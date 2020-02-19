
locals {
  network = cidrsubnet("172.16.0.0/12", 4, 2)
}

data "aws_vpc" "example" {
  id = var.vpc_id
}


resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
  lower   = false
  number  = true
}

data "aws_s3_bucket" "dmp_predictions" {
  bucket = "dmp-predictions"
}

module "s3_bucket" {
  source = "./modules/s3"
  bucket_object = data.aws_s3_bucket.dmp_predictions
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance-${random_string.random.result}"
  vpc_id = data.aws_vpc.example.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami                    = "ami-0dc9a8d2479a3c7d7"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-7039c038"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "terraform-example-${random_string.random.result}"
  }
}
