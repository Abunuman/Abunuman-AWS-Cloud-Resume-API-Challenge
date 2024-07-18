
resource "aws_lambda_function" "resume_fetcher" {
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  function_name    = "resume_fetcher"
  role             = aws_iam_role.lambda_get_item.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
}

# AWS IAM Role for the lambdaFunction
resource "aws_iam_role" "lambda_get_item" {
  name = "lambda_get_item_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Role Policy Attachment for Lambda Execution

resource "aws_iam_policy" "iam_policy_for_resume_fetcher" {
  name = "aws_iam_policy_for_resume_fetcher"
  path = "/"
  description = "AWS IAM Policy for managing the resume_fetcher role"
    policy = jsonencode(
      {
        Version = "2012-10-17"
        Statement = [
        
          {
            "Effect" : "Allow",
            "Action" : [
              "dynamodb: GetItem"
            ],
            "Resource" : "arn:aws:dynamodb:*:*:table/Resumes"
          }
        ]
      }
    

    )

}

resource "aws_iam_role_policy_attachment" "lambda_get_item_policy" {
  role       = aws_iam_role.lambda_get_item.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function URL
resource "aws_lambda_function_url" "resume_fetcher_url" {
  function_name = aws_lambda_function.resume_fetcher.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins   = ["*"]
    allow_methods   = ["*"]
    allow_headers   = ["date", "keep-alive"]
    expose_headers  = ["keep-alive", "date"]
    max_age         = 86400
  }
}

output "function_url" {
  value = aws_lambda_function_url.resume_fetcher_url.function_url
}