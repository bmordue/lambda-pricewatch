provider "aws" {
  profile = var.cli_profile
  region  = var.region
}

#TODO: KMS key
