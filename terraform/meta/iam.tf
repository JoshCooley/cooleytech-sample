resource "aws_iam_role" "cooley_tech" {
  name = "cooley.tech_build"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "AWS" : "*" },
      "Effect": "Deny",
      "Sid": ""
    }
  ]
}
EOF
}

output "ct_role_arn" {
  value = "${aws_iam_role.cooley_tech.arn}"
}
