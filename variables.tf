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
}

variable "repo_policies" {
  type        = map(object({ inline_policy = optional(string), managed_policy_arns = optional(list(string)) }))
  description = "Repository name and policy ARN key/value pairs"
}
