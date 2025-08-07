resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.project_name}-user-pool"
  tags = {
    Project = var.project_name
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "${var.project_name}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  explicit_auth_flows = ["USER_PASSWORD_AUTH", "ADMIN_NO_SRP_AUTH"]
}

# Resource to automatically create a user
resource "null_resource" "create_cognito_user" {
  depends_on = [aws_cognito_user_pool.user_pool]

  provisioner "local-exec" {
    command = "aws cognito-idp admin-create-user --user-pool-id ${aws_cognito_user_pool.user_pool.id} --username challengeuser --temporary-password Challenge2025! --message-action SUPPRESS"
  }
}