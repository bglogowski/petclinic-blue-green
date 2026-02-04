variable "infrastructure_version" {
  default = "1"
}

terraform {
  backend "s3" {
    bucket = "01-production"
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

