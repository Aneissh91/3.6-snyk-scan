provider "aws" {
  region = "ap-southeast-1" # Singapore region
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Attach basic execution policy (CloudWatch logging)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function definition
resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  # Zip file created by GitHub Actions workflow
  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}

# Output the Lambda name
output "lambda_name" {
  value = aws_lambda_function.hello_world.function_name
}
