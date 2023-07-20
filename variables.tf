variable "oidc_provider_arn" {
  type        = string
  description = "ARN of github actions oidc provider"
  default     = ""
}

variable "repo_policies" {
  type        = list(object({ repo = string, branches = optional(list(string)), inline_policy = optional(string), managed_policy_arns = optional(list(string)) }))
  description = "Repository name, branches and policies. If branches is empty then wildcard will be apply"
}
