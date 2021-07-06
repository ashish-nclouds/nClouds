variable "identifier" {
  description = "Name for the inline policy resource"
  type        = string
}

variable "description" {
  description = "Description for the IAM inline policy"
  default     = "Created by terraform"
  type        = string
}

variable "policy" {
  description = "Inline policy for the role"
  default     = ""
  type        = string
}

variable "role" {
  description = "Role name to which the inline policy to attach"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}
