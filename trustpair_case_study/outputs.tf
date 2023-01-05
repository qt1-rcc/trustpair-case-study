# Output value definitions

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.hello_world.function_name
}

output "cognito_pool_id" {
  description = "Cognito Pool ID"

  value = aws_cognito_user_pool.pool.id
}

output "cognito_client_id" {
  description = "Cognito client ID"

  value = aws_cognito_user_pool_client.client.id
}