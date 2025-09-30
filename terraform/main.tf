provider "aws" {
  region  = "ap-northeast-1"
  profile = "developer"
}

provider "aws" {
  alias   = "cloudfront"
  region  = "us-east-1"
  profile = "developer"
}
