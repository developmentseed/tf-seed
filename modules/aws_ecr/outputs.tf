output "registry_arn" {
  value = var.is_public ? aws_ecrpublic_repository.service[0].arn : aws_ecr_repository.service[0].arn
}

output "registry_name" {
  value = var.is_public ? aws_ecrpublic_repository.service[0].id : aws_ecr_repository.service[0].name
}

output "repository_url" {
  value = var.is_public ? aws_ecrpublic_repository.service[0].repository_uri : aws_ecr_repository.service[0].repository_url
}
