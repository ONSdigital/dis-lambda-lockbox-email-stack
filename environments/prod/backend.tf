terraform {
  # Assumes s3 bucket and dynamo DB table already set up
  # See https://github.com/ONSdigital/dp-infra-state-stack
  # - A configuration can only provide one backend block (only declare once)
  # - A backend block cannot refer to named values (like input variables, locals, or data source attributes)
  # - You cannot reference values declared within backend blocks elsewhere in the configuration
  backend "s3" {
    profile = "dp-prod"
    bucket  = "ons-dp-prod-encrypted-datasets"
    key    = "dis-lambda-lockbox-email-stack.tfstate"
    region = "eu-west-2"
    dynamodb_table = "dp-prod-terraform-remote-state-lock"
    encrypt        = true
  }
}
