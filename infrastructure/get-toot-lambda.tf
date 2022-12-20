resource "aws_lambda_function" "get_toot" {
  function_name     = "get_toot"
  filename          = "build/get-toot.zip"
  role              = local.iam_role
  handler           = "get-toot.handler"
  timeout           = 600
  runtime           = "python3.9"
  layers            = [aws_lambda_layer_version.mastodon_layer.arn]
  source_code_hash  = filebase64sha256(data.archive_file.get_toot.output_path)

  environment {
    variables = {
      TOOTS_TABLE_NAME = aws_dynamodb_table.toots.name
    }
  }
}

resource "aws_lambda_layer_version" "mastodon_layer" {
  s3_bucket           = "ai-art-tooter-src-bucket"
  s3_key              = "mastodon-layer.zip"
  layer_name          = "mastodon-layer"
  compatible_runtimes = ["python3.9"]
}

data "archive_file" "get_toot" {
  type        = "zip"
  source_dir  = "../${path.module}/source/get-toot/src/"
  output_path = "${path.module}/build/get-toot.zip"
}

resource "aws_cloudwatch_event_rule" "get_the_toots" {
  name                = "start-listener"
  description         = "Cronlike scheduled Cloudwatch Event"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "get_toot_lambda" {
  rule              = "${aws_cloudwatch_event_rule.get_the_toots.name}"
  target_id         = "${aws_lambda_function.get_toot.id}"
  arn               = "${aws_lambda_function.get_toot.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_get_toot" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.get_toot.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.get_the_toots.arn
}
