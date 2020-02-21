provider "aws" {
  profile = "cooley.tech"
  region  = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::474732792461:role/cooley.tech"
  }
}

resource "aws_ecr_repository" "cooley_tech" {
  name = "cooley.tech"
}
