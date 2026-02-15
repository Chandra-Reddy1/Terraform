provider "aws" {
  region = var.region
}

resource "aws_instance" "my-test" {
  count         = var.resource
  ami           = var.ami
  instance_type = var.aws_instance[1]
  tags          = var.map_tags
}


