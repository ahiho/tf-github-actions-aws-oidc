variable "org" {
  type        = string
  description = "Github organization name"
  default     = "ahiho"
}


variable "create_oidc_provider" {
  type        = bool
  description = "(optional) Create OIDC provider"
  default     = true
}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) Required if create_oidc_provider=false"
  default     = ""
  validation {
    condition     = var.create_oidc_provider == false
    error_message = "oidc_provider_arn is required if create_oidc_provider is false"
  }
}

variable "repo_policies" {
  type        = map(list(string))
  description = "Repository name and policy ARN key/value pairs"
}
