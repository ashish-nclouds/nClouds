
module "inline_policy" {
    source = "app.terraform.io/ncodelibrary/iam-inline-policy/aws"
    identifier = "${local.identifier}-${terraform.workspace}"
    role = "example_s3_role"
    policy = local.policy
}