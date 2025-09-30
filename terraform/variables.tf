variable "region" {
  default = "ap-northeast-1"
}

variable "profile" {
  default = "developer"
}

variable "bucket_name" {
  default = "jarujaru-island-gacha"
}

variable "api_repository_name" {
  default = "jarujaru-island-gacha-api"
}

variable "batch_repository_name" {
  default = "jarujaru-island-gacha-batch"
}

variable "api_docker_dir" {
  default = "../backend/api/Dockerfile"
}

variable "batch_docker_dir" {
  default = "../backend/batch/Dockerfile"
}

variable "api_lambda_function_name" {
  default = "jarujaru-island-gacha-api"
}

variable "batch_lambda_function_name" {
  default = "jarujaru-island-gacha-batch"
}

variable "cloudwatch_event_rule_name" {
  default = "jarujaru-island-gacha-batch"
}

variable "api_gateway_name" {
  default = "jarujaru-island-gacha"
}

variable "api_gateway_stage_name" {
  default = "prod"
}

variable "api_throttling_burst_limit" {
  type    = number
  default = 20
}

variable "api_throttling_rate_limit" {
  type    = number
  default = 10
}

variable "api_usage_plan_quota_limit" {
  type    = number
  default = 100
}

variable "api_gateway_api_key_value" {
  default = "AHCAGDNALSIURAJURAJAHCAGDNALSIURAJURAJ"
}

variable "supabase_url" {
  type = string
}

variable "supabase_key" {
  type = string
}

variable "youtube_api_key" {
  type = string
}

variable "channel_id" {
  type = string
}
