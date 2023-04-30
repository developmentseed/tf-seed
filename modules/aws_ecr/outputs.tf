output "registry_arn" {
  value = var.is_public ? aws_ecrpublic_repository.service.arn : aws_ecr_repository.service.arn
}

output "registry_name" {
  value = var.is_public ? aws_ecrpublic_repository.service.name : aws_ecr_repository.service.name
}

output "repository_url" {
  value = var.is_public ? aws_ecrpublic_repository.service.repository_url : aws_ecr_repository.service.repository_url
}
