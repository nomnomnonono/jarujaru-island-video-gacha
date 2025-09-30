data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_lambda_role" {
  name               = "jarujaru-island-gacha-api-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "batch_lambda_role" {
  name               = "jarujaru-island-gacha-batch-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_basic_execution" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "batch_basic_execution" {
  role       = aws_iam_role.batch_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "api" {
  function_name = var.api_lambda_function_name
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.api_repository.repository_url}:latest"
  role          = aws_iam_role.api_lambda_role.arn
  architectures = ["arm64"]
  timeout       = 30
  memory_size   = 1024

  environment {
    variables = {
      SUPABASE_URL = var.supabase_url
      SUPABASE_KEY = var.supabase_key
      BUCKET_NAME  = var.bucket_name
      REGION       = var.region
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.api_basic_execution,
    aws_ecr_repository.api_repository
  ]
}

resource "aws_lambda_function" "batch" {
  function_name = var.batch_lambda_function_name
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.batch_repository.repository_url}:latest"
  role          = aws_iam_role.batch_lambda_role.arn
  architectures = ["arm64"]
  timeout       = 900 # Lambdaの最大実行時間
  memory_size   = 1024

  environment {
    variables = {
      SUPABASE_URL    = var.supabase_url
      SUPABASE_KEY    = var.supabase_key
      YOUTUBE_API_KEY = var.youtube_api_key
      CHANNEL_ID      = var.channel_id
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.batch_basic_execution,
    aws_ecr_repository.batch_repository
  ]
}

resource "aws_cloudwatch_event_rule" "batch_daily" {
  name                = var.cloudwatch_event_rule_name
  description         = "毎日JST午前1時にBatch Lambdaを起動"
  schedule_expression = "cron(0 16 * * ? *)"
}

resource "aws_cloudwatch_event_target" "batch_daily" {
  rule      = aws_cloudwatch_event_rule.batch_daily.name
  target_id = aws_lambda_function.batch.function_name
  arn       = aws_lambda_function.batch.arn
}

resource "aws_lambda_permission" "batch_eventbridge" {
  statement_id  = "AllowEventBridgeInvokeBatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.batch_daily.arn
}
