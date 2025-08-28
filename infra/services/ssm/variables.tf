variable "environment" {
  type = string
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "app_env_content" {
  type        = string
  description = "The contents of the .env file"
}

variable "ssm_param_name" {
  type        = string
  description = "SSM parameter full name"
}

variable "ssm_param_description" {
  type        = string
  description = "Description of the SSM parameter"
}

variable "ssm_param_app_tag" {
  type        = string
  description = "App tag for the SSM parameter"
}
