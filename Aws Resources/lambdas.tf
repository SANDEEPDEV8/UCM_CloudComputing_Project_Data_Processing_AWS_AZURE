resource "aws_iam_role" "vehicle_data_lambda_exec" {
  name = "vehicle-data-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "vehicle_lambda_policy" {
  role       = aws_iam_role.vehicle_data_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_s3_upload_policy" {
  name        = "lambda-s3-upload-policy"
  description = "Allows Lambda function to upload files to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
      Resource = "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.bucket}/*"
    }]
  })
}

# Attach the IAM Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "lambda_s3_upload_policy_attachment" {
  role       = aws_iam_role.vehicle_data_lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_upload_policy.arn
}




data "archive_file" "vehicle_data_artifact" {
  type = "zip"

  source_dir  = "./lambdaCode"
  output_path = "./resource/vehicledata.zip"
}

resource "aws_s3_object" "lambda_vehicle_data" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "vehicledata.zip"
  source = data.archive_file.vehicle_data_artifact.output_path

  etag = filemd5(data.archive_file.vehicle_data_artifact.output_path)
}




resource "aws_lambda_function" "vehicle_data" {
  function_name = "vehicle-data"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_vehicle_data.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.vehicle_data_artifact.output_base64sha256

  role = aws_iam_role.vehicle_data_lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello" {
  name = "/aws/lambda/${aws_lambda_function.vehicle_data.function_name}"

  retention_in_days = 1
}

