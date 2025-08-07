resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

# Cognito resource for API Gateway Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name            = "${var.project_name}-authorizer"
  api_id          = aws_apigatewayv2_api.api.id
  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.user_pool_client.id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
  }
}

# Integrating Lambda with API Gateway
resource "aws_apigatewayv2_integration" "api_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api_lambda.arn
  integration_method     = "POST"
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# POST route /vpcs protected by Cognito
resource "aws_apigatewayv2_route" "api_post_route" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "POST /vpcs"
  target             = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# GET /vpcs route protected by Cognito
resource "aws_apigatewayv2_route" "api_get_route" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /vpcs"
  target             = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Deployment stage
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}