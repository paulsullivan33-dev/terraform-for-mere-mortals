terraform {
  required_version = ">= 1.6"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# A pretend server name, generated once and then kept in state.
resource "random_pet" "server" {
  length = 2
}

# A generated build identifier, four random bytes shown as hex.
resource "random_id" "build" {
  byte_length = 4
}

# Stands in for a generated credential. The random provider marks
# the result sensitive, and the output below does too.
resource "random_password" "admin_token" {
  length  = 16
  special = false
}

# A file that already exists in the project. The data source reads
# it while planning; Terraform creates and manages nothing here.
data "local_file" "banner" {
  filename = "${path.module}/banner.txt"
}

locals {
  banner_line = trimspace(data.local_file.banner.content)
}

# One generated page per name in var.page_names (for_each).
resource "local_file" "pages" {
  for_each = var.page_names

  filename = "${path.module}/out/${var.environment}-${each.key}.txt"
  content  = <<-EOT
    ${local.banner_line}
    Page: ${each.key}
    Server: ${random_pet.server.id}
    Message: ${var.message}
  EOT
}

# Identical build stamps, var.copies of them (count).
resource "local_file" "stamp" {
  count = var.copies

  filename = "${path.module}/out/stamp-${count.index}.txt"
  content  = "build ${random_id.build.hex}\n"
}

# Built into Terraform itself - no provider to install.
# Stores a snapshot of the current settings inside state,
# where other tooling could read it back via terraform output.
# Changing its input updates it in place; nothing outside
# Terraform is touched.
resource "terraform_data" "settings" {
  input = {
    environment = var.environment
    message     = var.message
    pages       = sort(tolist(var.page_names))
  }
}

# A small local module, called with three inputs.
module "note" {
  source = "./modules/note"

  title     = "Release note"
  body      = "Environment ${var.environment} deployed on ${random_pet.server.id}."
  directory = "${path.module}/out"
}

# Appends one line to a build log whenever the pages change.
# The triggers map is how a null_resource decides to re-run.
resource "null_resource" "build_log" {
  triggers = {
    pages_sha = sha256(join("", [for name in sort(keys(local_file.pages)) : local_file.pages[name].content_sha256]))
  }

  provisioner "local-exec" {
    command = "echo applied ${var.environment} on ${random_pet.server.id} >> ${path.module}/out/build.log"
  }
}
