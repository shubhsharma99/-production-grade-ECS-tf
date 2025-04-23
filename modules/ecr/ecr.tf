resource "aws_ecr_repository" "repo" {
  name = var.repo_name
}

// Repository Policy

# resource "aws_ecr_repository_policy" "repo_policy" {
#   repository = aws_ecr_repository.repo.name
#   policy     = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "AllowAllPublicPulls"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "ecr:BatchGetImage"
#         Resource  = "${aws_ecr_repository.repo.arn}/*"
#       }
#     ]
#   })
# }
