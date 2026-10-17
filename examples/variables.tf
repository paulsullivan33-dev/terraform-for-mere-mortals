variable "environment" {
  description = "Deployment label used in the generated file names."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "message" {
  description = "Line written into every generated page."
  type        = string
  default     = "Deployed by hand the first time."
}

variable "page_names" {
  description = "Names of the pages to generate, one file each."
  type        = set(string)
  default     = ["index", "about"]
}

variable "copies" {
  description = "How many identical build stamps to write."
  type        = number
  default     = 2

  validation {
    condition     = var.copies >= 1 && var.copies <= 5
    error_message = "copies must be between 1 and 5."
  }
}
