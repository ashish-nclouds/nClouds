
module "security_group_rule" {
  source            = "app.terraform.io/ncodelibrary/security-group-rules/aws"
  description       = "HTTPS for Public"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  ipv4_cidr         = [ "0.0.0.0/0" ]
  security_group    = "sg_example_id"
}