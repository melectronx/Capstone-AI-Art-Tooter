resource "aws_lambda_function" "get-toot" {
  function_name = "get-toot"
  filename       = "build/get-toot.zip"
  role          = local.iam_role
  handler       = "get-toot.handler"
  timeout       = 600
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.mastodon_layer.arn]
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
  role          = local.iam_role
  handler       = "post-toot.handler"
  timeout       = 300
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.mastodon_layer.arn]
  source_code_hash = filebase64sha256("build/post-toot.zip")  
  
  environment {
    variables = {
      TOOTS_TABLE_NAME = aws_dynamodb_table.toots.name
    }
  }
}


resource "aws_lambda_layer_version" "mastodon_layer" {
  s3_bucket     = "ai-art-tooter-src-bucket"
  s3_key        = "mastodon-layer.zip"
  layer_name    = "mastodon-layer"

  compatible_runtimes = ["python3.9"]
}

data "archive_file" "get-toot" {
  type        = "zip"
  source_file = "../${path.module}/source/get-toot/src/get-toot.py"
  output_path = "${path.module}/build/get-toot.zip"
}

data "archive_file" "post-toot" {
  type        = "zip"
  source_file = "../${path.module}/source/post-toot/src/post-toot.py"
  output_path = "${path.module}/build/post-toot.zip"
}
