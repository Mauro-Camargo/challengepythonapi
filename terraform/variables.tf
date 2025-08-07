variable "project_name" {
  description = "Project name to identify the resources."
  type        = string
  default     = "python-api-challenge"
}

variable "aws_region" {
  description = "The AWS region where the resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to store VPC data."
  type        = string
  default     = "PythonApiChallengeTable"
}

variable "lambda_zip_filename" {
  description = "Name of the Lambda code ZIP file."
  type        = string
  default     = "lambda.zip"
}

variable "lambda_code_bucket" {
  description = "Name of the S3 bucket where the Lambda code will be stored."
  type        = string
  default     = "python-vpc-challenge-lambda-code-bucket"
  
}