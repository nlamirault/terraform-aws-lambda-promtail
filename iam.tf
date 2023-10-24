# Copyright (C) Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

#-------------------------------------------------------------------------------
# IAM role assigned to the lambda function
#-------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge({
    Name = var.name
  }, var.tags)
}

#-------------------------------------------------------------------------------
# IAM policy assigned to lambda IAM role to be able to execute in VPC
#-------------------------------------------------------------------------------

data "aws_iam_policy" "lambda_vpc_execution" {
  count = length(var.lambda_vpc_subnets) > 0 ? 1 : 0

  name = "AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count = length(var.lambda_vpc_subnets) > 0 ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.lambda_vpc_execution[0].arn
}

#-------------------------------------------------------------------------------
# IAM policies attached to lambda IAM role
#-------------------------------------------------------------------------------

# CloudWatch

# These permissions are also included in the AWSLambdaVPCAccessExecutionRole IAM Policy
resource "aws_iam_role_policy" "lambda_cloudwatch" {
  count = length(var.lambda_vpc_subnets) == 0 ? 1 : 0

  name   = "cloudwatch"
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.lambda_cloudwatch[0].json
}

# These permissions are also included in the AWSLambdaVPCAccessExecutionRole IAM Policy
data "aws_iam_policy_document" "lambda_cloudwatch" {
  count = length(var.lambda_vpc_subnets) == 0 ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.this.arn,
    ]
  }
}

# KMS

resource "aws_iam_role_policy" "lambda_kms" {
  count = var.kms_key_arn != "" ? 1 : 0

  name   = "kms"
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.lambda_kms[0].json
}

data "aws_iam_policy_document" "lambda_kms" {
  count = var.kms_key_arn != "" ? 1 : 0

  statement {
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      var.kms_key_arn,
    ]
  }
}

# S3

resource "aws_iam_role_policy" "lambda_s3" {
  count = length(var.bucket_names) > 0 ? 1 : 0

  name   = "s3"
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.lambda_s3[0].json
}

data "aws_iam_policy_document" "lambda_s3" {
  count = length(var.bucket_names) > 0 ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      for _, bucket_name in var.bucket_names : "arn:aws:s3:::${bucket_name}/*"
    ]
  }

}

# Kinesis

resource "aws_iam_role_policy" "lambda_kinesis" {
  count = length(var.kinesis_stream_name) > 0 ? 1 : 0

  name   = "kinesis"
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.lambda_kinesis[0].json
}

data "aws_iam_policy_document" "lambda_kinesis" {
  count = length(var.kinesis_stream_name) > 0 ? 1 : 0

  statement {
    actions = [
      "kinesis:*",
    ]
    resources = [
      for _, stream in aws_kinesis_stream.this : stream.arn
    ]
  }
}

# SQS

data "aws_iam_policy_document" "queue_policy" {
  count = var.sqs_enabled ? 1 : 0
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = ["arn:aws:sqs:*:*:${var.sqs_queue_name_prefix}-main-queue"]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = local.bucket_arns
    }
  }
}

data "aws_iam_policy" "lambda_sqs_execution" {
  name = "AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_execution" {
  count      = var.sqs_enabled ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.lambda_sqs_execution.arn
}
