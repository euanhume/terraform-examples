variable "ocm_environment" {
  type    = string
  default = "production"
}

variable "openshift_version" {
  type    = string
  default = "4.12"
}

variable "account_role_prefix" {
  type    = string
  default = "ManagedOpenShift"
}

variable "token" {
  type = string
}

variable "url" {
  type    = string
  default = "https://api.openshift.com"
}