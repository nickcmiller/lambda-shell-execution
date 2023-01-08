# -- lambda_name/variables.tf --

variable "filename" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_timeout" {
  type = number
}

variable "lambda_runetime" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "role_policy_attachment" {}