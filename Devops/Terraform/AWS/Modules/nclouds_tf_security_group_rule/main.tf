

resource "aws_security_group_rule" "security_group_rule" {
  description       = var.description
  type              = var.type
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.protocol
  cidr_blocks       = var.ipv4_cidr
  security_group_id = var.security_group
}