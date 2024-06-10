output "first_arn" {
    value = aws_iam_user.example[0].arn
    description = "value of the first ARN"
}

output "all_arns"{
    value = aws_iam_user.example[*].arn
    description = "All ARNs of the created IAM users"
}