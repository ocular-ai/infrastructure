terraform {
  required_version = "1.17.2"

  cloud {
    organization = "ocular_ai"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6"
    }
  }
}
