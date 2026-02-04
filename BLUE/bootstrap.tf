variable "infrastructure_version" {
  default = "1"
}

terraform {
  backend "s3" {
    bucket = "01-prod-blue"
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

