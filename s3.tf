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

resource "aws_s3_bucket_notification" "sqs" {
  for_each = var.sqs_enabled ? var.bucket_names : []

  bucket = each.value
  queue {
    queue_arn     = aws_sqs_queue.main[0].arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log.gz"
    filter_prefix = "VPC_FL/"
  }
}

resource "aws_s3_bucket_notification" "this" {
  for_each = var.sqs_enabled ? [] : var.bucket_names

  bucket = each.value

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log.gz"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke_lambda_promtail
  ]
}
