terraform {
  # backend "s3" {
  #   profile = "" # add bucket profile
  #   encrypt = true
  #   bucket  = "" # add bucket name
  #   region  = "" # add region
  #   key     = "" # add key path on s3 bucket
  # }
  required_providers {
    aws = {
      version = "~> 4.25.0"
    }
  }
}

provider "aws" {
  profile = "default" # change profile if not default
  region  = "" # add region
}
