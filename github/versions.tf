terraform {
  required_version = ">= 1.6"

  cloud {
    organization = "ocular-ai"

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
