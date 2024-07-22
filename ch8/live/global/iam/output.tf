output "all_users"{
    value = aws_iam_user.example
    description = "All ARNs of the created IAM users"
}

output "all_arns"{
    value = values(aws_iam_user.example)[*].arn
    description = "All ARNs of the created IAM users"
}