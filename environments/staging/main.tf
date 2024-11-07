locals {
  # Only lowercase alphanumeric characters and hyphens allowed in `env_name`
  env_name = "dp-staging"
  region   = "eu-west-2"

  function_name = "lamdbda_email_function"
  tags = {
    Environment = local.env_name
    Repository  = "https://github.com/ONSdigital/dis-lambda-lockbox-email-stack"
    Stack       = "dis-lambda-lockbox-email-stack"
  }
}

provider "aws" {
  region  = local.region
  profile = "dp-staging"
}

module "lambda_example" {
  # source  = "terraform-aws-modules/lambda/aws"
  # version = "7.14.0"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git?ref=00a71723bbefb191c3fb622b3e34c693a2ca4930"

  function_name = local.function_name
  handler       = "lambda_email_function.lambda_handler"
  runtime       = "python3.12"
  publish       = true

  store_on_s3              = true
  s3_bucket                = module.s3_bucket.s3_bucket_id
  s3_prefix                = "${local.function_name}/"
  artifacts_dir            = "${path.root}/.terraform/lambda-builds/"
  recreate_missing_package = false

  source_path = [
    "${path.root}/../../src/lambda_function.py",
    {
      pip_requirements = "${path.root}/../../src/requirements.txt"
    }
  ]

  environment_variables = {
    email_source = "florence@dp-staging.aws.onsdigital.uk"
    bucket_name = "ons-dp-staging-encrypted-datasets"
    download_url = "download.dp-staging.aws.onsdigital.uk/downloads-new"
    email_recipient = "publishing@ons.gov.uk"
  }

  tags = local.tags
}

module "s3_bucket" {
  # source  = "terraform-aws-modules/s3-bucket/aws"
  # version = "4.2.1"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=d8ad14f2da0179178030c8876de84458aa7495e9"

  bucket        = "${local.env_name}-${local.function_name}"
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }
  tags = local.tags
}
