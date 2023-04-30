resource "aws_iam_user_policy" "deploy" {
  count  = var.enable_deploy_user ? 1 : 0
  name   = "${var.registry_name}-${var.environment}-deploy-policy"
  user   = var.iam_deploy_username
  policy = data.aws_iam_policy_document.deploy.json
}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      aws_ecr_repository.service.arn
    ]
  }
}

resource "aws_ecr_repository" "service" {
  count = var.is_public ? 0 : 1
  name = "tf-${var.registry_name}-${var.environment}"
  image_tag_mutability = var.mutable_image_tags ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = var.tags
}

resource "aws_ecrpublic_repository" "service" {
  count = var.is_public ? 1 : 0
  repository_name = "tf-${var.registry_name}-${var.environment}"
  tags = var.tags
}
