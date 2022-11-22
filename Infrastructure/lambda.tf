resource "aws_lambda_function" "get-toot" {
  function_name = "get-toot"
  filename       = "build/get-toot.zip"
  role          = "arn:aws:iam::534283426081:role/LabRole"
  handler       = "get-toot.handler"
  timeout       = 300
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.requests_layer.arn]
  source_code_hash = filebase64sha256("build/get-toot.zip")

  environment {
    variables = {
      TOOTS_TABLE_NAME = aws_dynamodb_table.toots.name
    }
  }
}

resource "aws_lambda_function" "post-toot" {
  function_name = "post-toot"
  filename       = "build/post-toot.zip"
  role          = "arn:aws:iam::534283426081:role/LabRole"
  handler       = "post-toot.handler"
  timeout       = 300
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.requests_layer.arn]
  source_code_hash = filebase64sha256("build/post-toot.zip")  
  
  environment {
    variables = {
      TOOTS_TABLE_NAME = aws_dynamodb_table.toots.name
    }
  }
}


resource "aws_lambda_layer_version" "requests_layer" {
  s3_bucket     = "ai-art-tooter-src-bucket"
  s3_key        = "requests-layer.zip"
  layer_name    = "requests-layer"

  compatible_runtimes = ["python3.9"]
}
