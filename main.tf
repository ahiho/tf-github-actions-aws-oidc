terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }

}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_oidc_provider ? 1 : 0
  client_id_list = [
    "sts.amazonaws.com",
    "https://github.com/${var.org}"
  ]

  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
  url             = "https://token.actions.githubusercontent.com"
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github_actions[0].arn : var.oidc_provider_arn
}


resource "aws_iam_role" "github_actions_role" {

  for_each = var.repo_policies

  name = "GithubAction_Role_${var.org}${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.org}/${each.key}"
          }
        }
      },
    ]
  })

  managed_policy_arns = each.value.managed_policy_arns

  dynamic "inline_policy" {
    for_each = length(each.value.inline_policy) > 0 ? [each.value.inline_policy] : []
    content {
      name   = "GithubAction_Policy_${each.key}"
      policy = inline_policy.value
    }
  }
}
