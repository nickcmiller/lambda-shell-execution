# -- iam/main.tf --

#LAMBDA PERMISSIONS

#Policy for Lambda to assume IAM role
resource "aws_iam_role" "lambda_role" {
  name = "assume-${var.lambda_name}-role"
  #References a file from the iam directory that has the Lambda's assume role IAM policy
  assume_role_policy = file("${path.module}/lambda_role.txt")
}

#Policy for the IAM role to use
resource "aws_iam_policy" "iam_policy_for_lambda_role" {
  name        = "aws-policy-for-${var.lambda_name}-role"
  description = "AWS IAM Policy for managing assume-lambda-role"
  #References a file from the iam directory that has the IAM policy for the role assumed
  policy = file("${path.module}/lambda_policy.txt")
}

#Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda_role.arn
}


#EC2 ROLE PERMISSIONS

#Role policy allowing EC2 instnances to assume the role
resource "aws_iam_role" "ec2_role_for_SSM" {
  name = "ec2-role-for-SSM"
  assume_role_policy = file("${path.module}/ec2_role.txt")
}

#Attaching the role to a Managed Role 
resource "aws_iam_policy_attachment" "ec2_ssm_attachment" {
  name       = "ec2-ssm-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles      = ["${aws_iam_role.ec2_role_for_SSM.name}"]
}

#instance profile to give EC2 instances ec2_role_for_SSM
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-profile"
  role = "${aws_iam_role.ec2_role_for_SSM.name}"
}