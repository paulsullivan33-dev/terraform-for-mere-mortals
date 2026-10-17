output "server_name" {
  description = "The generated name of the pretend server."
  value       = random_pet.server.id
}

output "generated_files" {
  description = "Files written by the pages resource."
  value       = [for name in sort(keys(local_file.pages)) : local_file.pages[name].filename]
}

output "note_file" {
  description = "Path of the file written by the note module."
  value       = module.note.file_path
}

output "banner_sha256" {
  description = "Checksum of the banner file, as read by the data source."
  value       = data.local_file.banner.content_sha256
}

output "settings" {
  description = "The settings snapshot stored by the terraform_data resource."
  value       = terraform_data.settings.output
}

output "admin_token" {
  description = "Generated admin token. Sensitive on purpose, so Terraform hides it in normal output."
  value       = random_password.admin_token.result
  sensitive   = true
}
