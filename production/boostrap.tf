variable "infrastructure_version" {
  default = "1"
}

terraform {
  backend "s3" {
    bucket = "cse-41381-bglogowski"
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

