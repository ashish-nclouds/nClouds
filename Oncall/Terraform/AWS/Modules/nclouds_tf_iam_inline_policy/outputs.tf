output "output" {
  value = {
    policy = aws_iam_role_policy.inline_policy.id
  }
}
