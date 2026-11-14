resource "github_repository" "delphi_ai" {
  name        = "delphi.ai"
  description = "delphi.ai - a Pytorch library from truncated statistics and everything in between"
  visibility  = "public"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = false

  # A repository destroyed by a bad plan takes its issues and PRs with it.
  archive_on_destroy = true
}

resource "github_repository" "infrastructure" {
  name        = "infrastructure"
  description = "The ocular-ai organization's GitHub settings, as Terraform."
  visibility  = "public"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  delete_branch_on_merge = true

  archive_on_destroy = true
}

resource "github_repository" "website" {
  name         = "pstefanou12.github.io"
  description  = "Resume Website"
  homepage_url = "https://ocular-ai.github.io/pstefanou12.github.io/"
  visibility   = "public"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = false
  delete_branch_on_merge = false

  archive_on_destroy = true
}

resource "github_repository_pages" "website" {
  repository = github_repository.website.name
  build_type = "legacy"

  source {
    branch = "main"
    path   = "/"
  }
}

# The apply workflow's gate: it runs only from main, after a reviewer approves.
resource "github_repository_environment" "infrastructure_production" {
  repository  = github_repository.infrastructure.name
  environment = "production"

  reviewers {
    users = [local.pstefanou12]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
