#Defines name, determine the timeout time, and decide the runtime for Lambda function
locals {
  lambda_name     = "execute-shell-script"
  lambda_timeout  = 20
  lambda_runetime = "python3.8"
}

#Module containing IAM permissions used by Lambda
module "iam" {
  lambda_name = local.lambda_name
  source      = "./iam"
}

#Creates zip file for the lambda_handler 
data "archive_file" "zip_the_handler_code" {
  type = "zip"
  # Creates a zip archive file by combining the contents of the "handler" directory and saving it to the specified output path
  source_dir = "${path.module}/handler/"
  # The output path for the zip file is set to a file named after the value of the "lambda_name" local variable
  output_path = "${path.module}/handler/${local.lambda_name}.zip"
}

#Module creating the Lambda function
module "lambda" {
  source          = "./lambda"
  lambda_name     = local.lambda_name
  lambda_timeout  = local.lambda_timeout
  lambda_runetime = local.lambda_runetime
  #The IAM role that the lambda function should assume
  lambda_role_arn = module.iam.lambda_role_arn
  #The IAM policy attached to that role
  role_policy_attachment = module.iam.role_policy_attachment
  filename               = "${path.module}/handler/${local.lambda_name}.zip"
}

#Module containing test instance for shell script
module "ec2" {
  source      = "./ec2"
}
