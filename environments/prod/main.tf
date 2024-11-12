locals {
  # Only lowercase alphanumeric characters and hyphens allowed in `env_name`
  env_name = "dp-prod"
  region   = "eu-west-2"

  function_name = "lambda_email_function"
  tags = {
    Environment = local.env_name
    Repository  = "https://github.com/ONSdigital/dis-lambda-lockbox-email-stack"
    Stack       = "dis-lambda-lockbox-email-stack"
  }
}

provider "aws" {
  region  = local.region
  profile = "dp-prod"
}

module "lambda_email_function" {
  # source  = "terraform-aws-modules/lambda/aws"
  # version = "7.14.0"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git?ref=00a71723bbefb191c3fb622b3e34c693a2ca4930"

  function_name = local.function_name
  handler       = "lambda_email_function.lambda_handler"
  runtime       = "python3.12"
  publish       = true

  role = aws_iam_role.lambda_exec_role.arn

  store_on_s3              = true
  s3_bucket                = "ons-dp-prod-encrypted-datasets"
  s3_prefix                = "${local.function_name}/"
  artifacts_dir            = "${path.root}/.terraform/lambda-builds/"
  recreate_missing_package = false

  source_path = [
    "${path.root}/../../src/lambda_email_function.py",
    {
      pip_requirements = "${path.root}/../../src/requirements.txt"
    }
  ]

  environment_variables = {
    email_source = "florence@dp-prod.aws.onsdigital.uk"
    bucket_name = "ons-dp-prod-encrypted-datasets"
    download_url = "download.ons.gov.uk/downloads-new"
    email_recipient = "publishing@ons.gov.uk"
  }

  tags = local.tags
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "${local.env_name}-lambda-ses-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ses_send_email_policy" {
  name        = "${local.env_name}-lambda-ses-policy"
  description = "Policy to allow Lambda function to send emails using SES"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ses:SendEmail",
        Resource = "arn:aws:ses:eu-west-2:961848014982:identity/florence@dp-prod.aws.onsdigital.uk"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ses_send_email_policy.arn
}

module "s3_bucket" {
  # source  = "terraform-aws-modules/s3-bucket/aws"
  # version = "4.2.1"
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=d8ad14f2da0179178030c8876de84458aa7495e9"

  bucket        = "dp-prod-${local.function_name}"
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

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = "ons-dp-prod-encrypted-datasets"

  lambda_function {
    lambda_function_arn = module.lambda_email_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "ts-datasets/"
  }

  depends_on = [module.lambda_email_function]
}
