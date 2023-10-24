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

# tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "this" {
  image_uri     = var.lambda_promtail_image
  function_name = var.name
  role          = aws_iam_role.this.arn
  kms_key_arn   = var.kms_key_arn

  timeout      = 60
  memory_size  = 128
  package_type = "Image"

  # From the Terraform AWS Lambda docs: If both subnet_ids and security_group_ids are empty then vpc_config is considered to be empty or unset.
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = var.lambda_vpc_subnets
    security_group_ids = var.lambda_vpc_security_groups
  }

  environment {
    variables = {
      WRITE_ADDRESS            = var.write_address
      USERNAME                 = var.username
      PASSWORD                 = var.password
      BEARER_TOKEN             = var.bearer_token
      KEEP_STREAM              = var.keep_stream
      BATCH_SIZE               = var.batch_size
      EXTRA_LABELS             = var.extra_labels
      DROP_LABELS              = var.drop_labels
      OMIT_EXTRA_LABELS_PREFIX = var.omit_extra_labels_prefix ? "true" : "false"
      TENANT_ID                = var.tenant_id
      SKIP_TLS_VERIFY          = var.skip_tls_verify
      PRINT_LOG_LINE           = var.print_log_line
    }
  }

  tags = merge({
    Name = var.name
  }, var.tags)

  depends_on = [
    aws_iam_role_policy.lambda_s3,
    aws_iam_role_policy.lambda_kms,
    aws_iam_role_policy.lambda_kinesis,
    aws_iam_role_policy.lambda_cloudwatch,

    aws_iam_role_policy_attachment.lambda_vpc_execution,

    # Ensure function is created after, and destroyed before, the log-group
    # This prevents the log-group from being re-created by an invocation of the lambda-function
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_lambda_function_event_invoke_config" "this" {
  function_name          = aws_lambda_function.this.function_name
  maximum_retry_attempts = 2
}

resource "aws_lambda_permission" "lambda_promtail_allow_cloudwatch" {
  count = length(var.log_group_names) > 0 ? 1 : 0

  statement_id  = "lambda-promtail-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
}

resource "aws_lambda_permission" "allow_s3_invoke_lambda_promtail" {
  for_each = var.bucket_names

  statement_id  = "lambda-promtail-allow-s3-bucket-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value}"
}

resource "aws_lambda_event_source_mapping" "this" {
  for_each = aws_kinesis_stream.this

  event_source_arn  = each.value.arn
  function_name     = aws_lambda_function.this.arn
  starting_position = "LATEST"
}
