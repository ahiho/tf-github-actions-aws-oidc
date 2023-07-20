terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  for_each = {
    for index, rp in var.repo_policies :
    sha1("${rp.repo}/${join(",", coalescelist(rp.branches, ["*"]))}") => rp
  }

  name = substr("GithubAction_${substr(md5(join(",", coalescelist(each.value.branches, ["*"]))), 0, 16)}_${replace(each.value.repo, "/", "@")}", 0, 64)

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
          StringLike = {
            "token.actions.githubusercontent.com:sub" : contains(coalescelist(each.value.branches, ["*"]), "*") ? "repo:${each.value.repo}:*" : [for branch in each.value.branches : "repo:${each.value.repo}:ref:refs/heads/${branch}"]
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  managed_policy_arns = each.value.managed_policy_arns

  dynamic "inline_policy" {
    for_each = each.value.inline_policy != null && length(each.value.inline_policy) > 0 ? [each.value.inline_policy] : []
    content {
      name   = "GithubAction_Policy_${replace(each.key, "/", "@")}"
      policy = inline_policy.value
    }
  }
}
