# AWS Security group Ingress/Egress rules Terraform Module

Terraform module to provision [`Security Group Rule `](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) on AWS.

## Usage

Use this module to add security group rules in SG

### Setup

For [`Security Group`] follow https://github.com/nclouds/terraform-aws-security-group]
Create a IAM Inline Policy.
```hcl

    module "security_group_rule" {
      source            = "../modules/nclouds_tf_security_group_rule"
      description       = "HTTPS to access Publically"
      type              = "ingress"
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      ipv4_cidr         = [ "0.0.0.0/o" ]
      security_group    = "sg_example_id"
    }
```

## Examples
Here are some working examples of using this module:
- [`examples/`](examples/)


For Ingress/Egress with ipv6, add ipv6_cidr in resource and module
```hcl
  ipv6_cidr_blocks  = [ "::/0" ]
```

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
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| append\_workspace | Appends the terraform workspace at the end of resource names, <identifier>-<worspace> | `bool` | `true` | no |
| description | Description for SG rule | `string` | `na` | yes |
| path | Path level of the SG Rule | `string` | `"/"` | no |
| type | Specify Ingress/Egress | `string` | `"na"` | yes |
| from_port | From Port | `number` | `"na"` | yes |
| to_port | To Port | `number` | `"na"` | yes |
| protocol | Protocol TCP/UDP | `string` | `"na"` | yes |
| cidr_blocks | IPv4 address/ network/ security groups | `list(string)` | `"na"` | yes |
| security_group_id | Security group id for the rule | `string` | `"na"` | yes |

## Outputs

| Name | Description |
|------|-------------|
| output | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing
If you want to contribute to this repository check all the guidelines specified [here](.github/CONTRIBUTING.md) before submitting a new PR.