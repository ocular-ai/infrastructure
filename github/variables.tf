variable "github_app_id" {
  description = "The ocular-ai-infrastructure GitHub App's ID."
  type        = string
}

variable "github_app_installation_id" {
  description = "The App's installation ID in the ocular-ai organization."
  type        = string
}

variable "github_app_pem_file" {
  description = "The App's private key, PEM-encoded."
  type        = string
  sensitive   = true
}
