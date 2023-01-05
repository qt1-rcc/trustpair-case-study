terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
    default_tags {
        tags = {
            Environment = "dev"
        }
    }
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "trustpair-demo-bucket"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld_py"
  vpc_config {
    subnet_ids = [for o in aws_subnet.euw_api_private_subnet : o.id]
    security_group_ids = [aws_security_group.allow_http.id]
  }

  filename      = "function.zip"
  runtime       = "python3.8"
  handler       = "main.handler"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 7
}


###
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 7
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}


###
resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

###
resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.lambda.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "http://localhost:4566/${aws_cognito_user_pool.pool.id}"
  }
}

resource "aws_apigatewayv2_integration" "function" {
  api_id                 = aws_apigatewayv2_api.lambda.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.hello_world.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route_get" {
  api_id             = aws_apigatewayv2_api.lambda.id
  #authorizer_id      = aws_apigatewayv2_authorizer.auth.id
  target             = "integrations/${aws_apigatewayv2_integration.function.id}"
  #authorization_type = "JWT"
  route_key = "GET /"
}

resource "aws_apigatewayv2_route" "route_post" {
  api_id             = aws_apigatewayv2_api.lambda.id
  authorizer_id      = aws_apigatewayv2_authorizer.auth.id
  target             = "integrations/${aws_apigatewayv2_integration.function.id}"
  authorization_type = "JWT"
  route_key = "POST /"
}

resource "aws_apigatewayv2_route" "route_integration" {
  api_id             = aws_apigatewayv2_api.lambda.id
  authorization_type = "AWS_IAM"
  route_key = "POST /"
  target             = "integrations/${aws_apigatewayv2_integration.function.id}"
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.lambda_exec.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}