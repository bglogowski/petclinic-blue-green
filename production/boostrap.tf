variable "infrastructure_version" {
  default = "1"
}

terraform {
  backend "s3" {
    bucket = "cse-41381-terraform-bucket"
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

