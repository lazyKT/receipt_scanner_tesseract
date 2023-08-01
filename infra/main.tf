terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "ap-southeast-1"
}


resource "aws_s3_bucket" "receipt-upload-bucket" {
    bucket = "receipt-image-upload-bucket"

    tags = {
        Name = "Receipt image upload bucket"
        Environment = "Dev"
    }
}


# iam role for the lambda
resource "aws_iam_role" "lambda_role" {
    name = "terraform_aws_lambda_role"
    assume_role_policy = <<EOF
    {
        "Version" : "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Effect" : "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}


# iam policy for the lambda
resource "aws_iam_role_policy" "iam_policy_for_lambda" {
    name = "aws_iam_policy_for_terraform_aws_lambda_role"
    role = aws_iam_role.lambda_role.id
     policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Creation of Lambda
resource "aws_lambda_function" "test_lambda" {
    function_name = "test_lambda"
    role = aws_iam_role.lambda_role.arn
    handler = "src/lambda_function.lambda_handler"
    runtime = var.runtime
    filename = "../src.zip"
    source_code_hash = filebase64sha256("../src.zip")
}


variable "lambda_role_name" {
    type    = string
    default = "ForLambdaExecution"
}

variable "runtime" {
  type = string
  default = "python3.10"
}





