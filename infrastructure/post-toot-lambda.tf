resource "aws_lambda_function" "post_toot" {
  function_name = "post_toot"
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

data "archive_file" "post_toot" {
  type        = "zip"
  source_dir = "../${path.module}/source/post-toot/src/"
  output_path = "${path.module}/build/post-toot.zip"
}

data "aws_s3_bucket" "art_bucket" {
  bucket = "ai-art-tooter-img"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_toot.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.art_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.art_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.post_toot.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}
