# The repositories existed before this one managed them. Once an apply has
# imported them, these blocks are no-ops and can be deleted.

import {
  to = github_repository.delphi_ai
  id = "delphi.ai"
}

import {
  to = github_repository.infrastructure
  id = "infrastructure"
}

import {
  to = github_repository.website
  id = "pstefanou12.github.io"
}

import {
  to = github_repository_pages.website
  id = "pstefanou12.github.io"
}

# GitHub created it, unprotected, when the first push's Apply job named it.
import {
  to = github_repository_environment.infrastructure_production
  id = "infrastructure:production"
}
