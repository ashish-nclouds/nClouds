variable "description" {
  description = "Description about the rule"
  type        = string
}

variable "type" {
    description = "Ingress / Egress"
    type = string
}

variable "from_port" {
    description = "Add From port"
    type = number
}

variable "to_port" {
    description = "Add To port"
    type = number
}

variable "protocol" {
    description = "Add Protocol tcp/udp"
    type = string
}

variable "ipv4_cidr" {
    description = "Add CIDR/IP to SG"
    type = list(string)
}

variable "security_group" {
    description = "Add Security group id"
    type = string
}