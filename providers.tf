# Authenticates as the ocular-ai-infrastructure GitHub App, whose
# credentials the Terraform Cloud workspace holds as sensitive variables.
provider "github" {
  owner = "ocular-ai"

  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
}
