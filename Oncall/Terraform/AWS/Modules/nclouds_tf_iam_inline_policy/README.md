# AWS Identity and Access Management Inline Policy (IAM Inline Policy) Terraform Module

Terraform module to provision [`IAM Policy`](https://aws.amazon.com/iam/) on AWS.

## Usage

Use this module either to add inline policy to existing Role or can use with IAM Role module.

### Setup

For [`IAM role`] follow https://github.com/nclouds/terraform-aws-iam-role]
Create a IAM Inline Policy.
```hcl
    module "inline_policy" {
        source = "app.terraform.io/ncodelibrary/iam-inline-policy/aws"
        identifier = "example-iam-policy"
        role = "role_name"   
        policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": "*"
            }
        ]
    }
    EOF
    }
```

## Examples
Here are some working examples of using this module:
- [`examples/`](examples/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| append\_workspace | Appends the terraform workspace at the end of resource names, <identifier>-<worspace> | `bool` | `true` | no |
| description | Description for the IAM policy | `string` | `"Created by terraform"` | no |
| identifier | Name for the resources | `string` | n/a | yes |
| path | Path level of the IAM policy | `string` | `"/"` | no |
| role | Role to which the inline policy to attach | `string` | `"/"` | yes |
| policy | JSON with the policy to be used | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| output | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing
If you want to contribute to this repository check all the guidelines specified [here](.github/CONTRIBUTING.md) before submitting a new PR.