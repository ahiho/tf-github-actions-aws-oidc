variable "oidc_provider_arn" {
  type        = string
  description = "ARN of github actions oidc provider"
  default     = ""
}

variable "repo_policies" {
  type        = map(object({ inline_policy = optional(string), managed_policy_arns = optional(list(string)) }))
  description = "Repository name and policy ARN key/value pairs"
}
