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

resource "aws_sqs_queue" "main" {
  count                      = var.sqs_enabled ? 1 : 0
  name                       = "${var.sqs_queue_name_prefix}-main-queue"
  sqs_managed_sse_enabled    = true
  policy                     = data.aws_iam_policy_document.queue_policy[0].json
  visibility_timeout_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter[0].arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "dead_letter" {
  count                   = var.sqs_enabled ? 1 : 0
  name                    = "${var.sqs_queue_name_prefix}-dead-letter-queue"
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_redrive_allow_policy" "this" {
  count     = var.sqs_enabled ? 1 : 0
  queue_url = aws_sqs_queue.dead_letter[0].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.main[0].arn]
  })
}
