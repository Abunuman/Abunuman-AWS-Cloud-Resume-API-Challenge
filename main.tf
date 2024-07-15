# resource "aws_dynamodb_table" "resumes" {
#   name           = "Resumes"
#   hash_key       = "id"
#   billing_mode   = "PAY_PER_REQUEST"

#   attribute {
#     name = "id"
#     type = "S"
#   }
# }

resource "aws_lambda_function" "resume_fetcher" {
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  function_name    = "resume_fetcher"
  role             = aws_iam_role.lambda_get_item.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
}

# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda_exec_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

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
# resource "aws_iam_policy" "iam_policy_for_resume_fetcher_logs" {
#   name = "aws_iam_policy_for_resume_fetcher logs"
#   path = "/"
#   description = "AWS IAM Policy for managing the resume_fetcher logs"
#     policy = jsonencode(
#       {
#         Version = "2012-10-17"
#         Statement = [
        
#           {
#             "Action" : [
#               "logs: CreateLogGroup",
#               "logs: CreateLogStream",
#               "logs: PutLogEvents"
#             ],
#             "Resource" : "arn:aws:logs:*:*:*",
#             "Effect" :"Allow"
#           }
#         ]
#       }
    

#     )

# }

# resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

resource "aws_iam_role_policy_attachment" "lambda_get_item_policy" {
  role       = aws_iam_role.lambda_get_item_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

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

# data "archive_file" "zip" {
#   type  = "zip"
#   source_dir = "${path.module}/lambda"
#   output_path = "${path.module}/packedlambda.zip"
# }

# resource "aws_api_gateway_rest_api" "resume_api" {
#   name = "ResumeAPI"
# }

# resource "aws_api_gateway_resource" "resume_resource" {
#   rest_api_id = aws_api_gateway_rest_api.resume_api.id
#   parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
#   path_part   = "resume"
# }

# resource "aws_api_gateway_method" "get_resume" {
#   rest_api_id   = aws_api_gateway_rest_api.resume_api.id
#   resource_id   = aws_api_gateway_resource.resume_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_integration" {
#   rest_api_id = aws_api_gateway_rest_api.resume_api.id
#   resource_id = aws_api_gateway_resource.resume_resource.id
#   http_method = aws_api_gateway_method.get_resume.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.resume_fetcher.invoke_arn
# }

# resource "aws_lambda_permission" "api_gateway" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.resume_fetcher.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*"
# }

# output "api_url" {
#   value = "${aws_api_gateway_rest_api.resume_api.execution_arn}/resume/{id}"
# }

