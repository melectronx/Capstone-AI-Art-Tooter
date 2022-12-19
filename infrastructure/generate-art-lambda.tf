resource "aws_lambda_function" "generate_art" {
  depends_on = [
   null_resource.ecr_image
 ]
  function_name = "generate_art"
  image_uri     = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  role          = local.iam_role
  timeout       = 600
  package_type  = "Image"
  

  environment {
    variables = {
      TOOTS_TABLE_NAME = aws_dynamodb_table.toots.name
    }
  }
}

resource "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
}

resource "null_resource" "ecr_image" {
 triggers = {
   python_file = md5(file("../${path.module}/source/generate-art/src/generate-art.py"))
   docker_file = md5(file("../${path.module}/source/generate-art/src/Dockerfile"))
 }
 
 provisioner "local-exec" {
   command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
           cd ../${path.module}/source/generate-art/src/
           docker build -t ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag} .
           docker push ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag}
       EOF
 }
}
data aws_ecr_image lambda_image {
 depends_on = [
   null_resource.ecr_image
 ]
 repository_name = local.ecr_repository_name
 image_tag       = local.ecr_image_tag
}
 



resource "aws_lambda_event_source_mapping" "toots_table_update" {
  event_source_arn  = aws_dynamodb_table.toots.stream_arn
  function_name     = aws_lambda_function.generate_art.arn
  starting_position = "LATEST"
}