output "iam_role_arns" {
  depends_on  = [aws_iam_role.github]
  description = "ARN of create IAM roles"
  value       = [for o in aws_iam_role.github : o.arn]
}