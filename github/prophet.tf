# Adopt the existing repository; review the import plan before applying.
import {
  to = github_repository.prophet
  id = "prophet"
}

resource "github_repository" "prophet" {
  name        = "prophet"
  description = "A multi-model chat application for ocular-ai."
  visibility  = "private"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
}

# Land Prophet's CI workflow before applying this ruleset.
resource "github_repository_ruleset" "prophet_default_branch" {
  name        = "default branch"
  repository  = github_repository.prophet.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    bypass_mode = "pull_request"
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      required_approving_review_count = 1
      require_last_push_approval      = true
    }

    required_status_checks {
      strict_required_status_checks_policy = false
      required_check {
        context = "check"
      }
      required_check {
        context = "tests"
      }
    }

    merge_queue {
      merge_method                      = "SQUASH"
      grouping_strategy                 = "ALLGREEN"
      max_entries_to_build              = 5
      min_entries_to_merge              = 1
      max_entries_to_merge              = 5
      min_entries_to_merge_wait_minutes = 0
      check_response_timeout_minutes    = 30
    }
  }
}
