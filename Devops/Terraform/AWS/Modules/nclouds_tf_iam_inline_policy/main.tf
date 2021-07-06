locals {
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_iam_role_policy" "inline_policy" {
  description = var.description
  name        = var.identifier
  role        = var.role
  policy      = var.policy
}
