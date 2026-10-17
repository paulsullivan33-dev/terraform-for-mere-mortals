terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "title" {
  description = "First line of the note."
  type        = string
}

variable "body" {
  description = "Body text of the note."
  type        = string
}

variable "directory" {
  description = "Directory the note file is written into."
  type        = string
}

resource "local_file" "note" {
  filename = "${var.directory}/note.txt"
  content  = "${var.title}\n\n${var.body}\n"
}

output "file_path" {
  description = "Path of the written note file."
  value       = local_file.note.filename
}

output "checksum" {
  description = "SHA-256 of the note file's content."
  value       = local_file.note.content_sha256
}
