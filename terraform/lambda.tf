# The Lambda function
resource "aws_lambda_function" "api_lambda" {
  function_name    = "${var.project_name}-api-lambda"
  handler          = "app.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn

  s3_bucket = aws_s3_object.lambda_code_zip.bucket
  s3_key    = aws_s3_object.lambda_code_zip.key

  source_code_hash = data.archive_file.lambda_zip_content.output_base64sha256
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.vpc_challenge_table.name
    }
  }

  tags = {
    Project = var.project_name
  }
}

# Upload the Lambda ZIP file to S3
resource "aws_s3_object" "lambda_code_zip" {
  bucket = var.lambda_code_bucket
  key    = var.lambda_zip_filename
  # The correct path is to the root directory (..) and not to the subdirectory (../lambda/)
  source = data.archive_file.lambda_zip_content.output_path

  tags = {
    Project = var.project_name
  }
}

# This resource creates the ZIP file from your 'lambda' folder and calculates the hash
data "archive_file" "lambda_zip_content" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda.zip"
   # Where the ZIP file will be created
}