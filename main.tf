terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  for_each = var.repo_policies
  name = "GithubAction_Role_${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" : "repo:${replace(each.key, "/", "@")}"
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  managed_policy_arns = each.value.managed_policy_arns

  dynamic "inline_policy" {
    for_each = length(each.value.inline_policy) > 0 ? [each.value.inline_policy] : []
    content {
      name   = "GithubAction_Policy_${replace(each.key, "/", "@")}"
      policy = inline_policy.value
    }
  }
}
