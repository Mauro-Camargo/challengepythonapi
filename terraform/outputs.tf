output "api_gateway_url" {
  description = "The invocation URL of the API Gateway."
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used by the Lambda function."
  value       = aws_dynamodb_table.vpc_challenge_table.name
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.user_pool.id
}

output "lambda_function_name" {
  value = aws_lambda_function.api_lambda.function_name
}