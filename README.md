# AWS Lambda Promtail

## Documentation

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.lambdafunction_logfilter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_sqs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_lambda_event_source_mapping.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.allow_s3_invoke_lambda_promtail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.lambda_promtail_allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_sqs_queue.dead_letter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_redrive_allow_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource |
| [aws_iam_policy.lambda_sqs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.lambda_vpc_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_batch_size"></a> [batch\_size](#input\_batch\_size) | Determines when to flush the batch of logs (bytes). | `string` | `""` | no |
| <a name="input_bearer_token"></a> [bearer\_token](#input\_bearer\_token) | The bearer token, necessary if target endpoint requires it. | `string` | `""` | no |
| <a name="input_bucket_names"></a> [bucket\_names](#input\_bucket\_names) | List of S3 bucket names to create Event Notifications for. | `set(string)` | `[]` | no |
| <a name="input_drop_labels"></a> [drop\_labels](#input\_drop\_labels) | Comma separated list of labels to be drop, in the format 'name1,name2,...,nameN' to be omitted to entries forwarded by lambda-promtail. | `string` | `""` | no |
| <a name="input_extra_labels"></a> [extra\_labels](#input\_extra\_labels) | Comma separated list of extra labels, in the format 'name1,value1,name2,value2,...,nameN,valueN' to add to entries forwarded by lambda-promtail. | `string` | `""` | no |
| <a name="input_keep_stream"></a> [keep\_stream](#input\_keep\_stream) | Determines whether to keep the CloudWatch Log Stream value as a Loki label when writing logs from lambda-promtail. | `string` | `"false"` | no |
| <a name="input_kinesis_stream_name"></a> [kinesis\_stream\_name](#input\_kinesis\_stream\_name) | Enter kinesis name if kinesis stream is configured as event source in lambda. | `set(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | kms key arn for encrypting env vars. | `string` | `""` | no |
| <a name="input_lambda_promtail_image"></a> [lambda\_promtail\_image](#input\_lambda\_promtail\_image) | The ECR image URI to pull and use for lambda-promtail. | `string` | `""` | no |
| <a name="input_lambda_vpc_security_groups"></a> [lambda\_vpc\_security\_groups](#input\_lambda\_vpc\_security\_groups) | List of security group IDs associated with the Lambda function. | `list(string)` | `[]` | no |
| <a name="input_lambda_vpc_subnets"></a> [lambda\_vpc\_subnets](#input\_lambda\_vpc\_subnets) | List of subnet IDs associated with the Lambda function. | `list(string)` | `[]` | no |
| <a name="input_log_group_names"></a> [log\_group\_names](#input\_log\_group\_names) | List of CloudWatch Log Group names to create Subscription Filters for. | `set(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used for created AWS resources. | `string` | `"lambda_promtail"` | no |
| <a name="input_omit_extra_labels_prefix"></a> [omit\_extra\_labels\_prefix](#input\_omit\_extra\_labels\_prefix) | Whether or not to omit the prefix `__extra_` from extra labels defined in the variable `extra_labels`. | `bool` | `false` | no |
| <a name="input_password"></a> [password](#input\_password) | The basic auth password, necessary if writing directly to Grafana Cloud Loki. | `string` | `""` | no |
| <a name="input_print_log_line"></a> [print\_log\_line](#input\_print\_log\_line) | Determines whether we want the lambda to output the parsed log line before sending it on to promtail. Value needed to disable is the string 'false' | `string` | `"true"` | no |
| <a name="input_skip_tls_verify"></a> [skip\_tls\_verify](#input\_skip\_tls\_verify) | Determines whether to verify the TLS certificate | `string` | `"false"` | no |
| <a name="input_sqs_enabled"></a> [sqs\_enabled](#input\_sqs\_enabled) | Enables sending S3 logs to an SQS queue which will trigger lambda-promtail, unsuccessfully processed message are sent to a dead-letter-queue | `bool` | `false` | no |
| <a name="input_sqs_queue_name_prefix"></a> [sqs\_queue\_name\_prefix](#input\_sqs\_queue\_name\_prefix) | Name prefix for SQS queues | `string` | `"s3-to-lambda-promtail"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for Lambda Promtail | `map(string)` | <pre>{<br>  "made-by": "terraform"<br>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID to be added when writing logs from lambda-promtail. | `string` | `""` | no |
| <a name="input_username"></a> [username](#input\_username) | The basic auth username, necessary if writing directly to Grafana Cloud Loki. | `string` | `""` | no |
| <a name="input_write_address"></a> [write\_address](#input\_write\_address) | This is the Loki Write API compatible endpoint that you want to write logs to, either promtail or Loki. | `string` | `"http://localhost:8080/loki/api/v1/push"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
