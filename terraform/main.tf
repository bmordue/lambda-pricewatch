
#dynamodb tables

#sns topics

#sns subscriptions

#iam roles

#lambda functions

##eventstream mappings
##env vars

#policies

#kms key 

provider "aws" {
  profile    = "${var.cli_profile}"
  region     = "${var.region}"
}
