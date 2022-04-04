variable "project" {
  type        = string
  description = "Solution name, e.g. `\"app\"` or `\"jenkins\"`"
}

variable "customer" {
  type        = string
  description = "Customer name"
}

variable "application" {
  type        = string
  description = "Type of application, e.g. `\"backend\"`, `\"frontend\"` or `\"keycloak\"`"
}

variable "stage" {
  type        = string
  description = "Environment stage, e.g. `\"dev\"`, `\"staging\"` or `\"production\"`"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `{BusinessUnit = \"XYZ\"}`"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}
