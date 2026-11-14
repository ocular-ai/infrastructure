locals {
  # GitHub user IDs, which outlive a username change.
  pstefanou12 = 35354411
}

# PRs run the quick tier; the merge queue runs the sharded not-slow suite on
# the merged result, which is what `tests` reports there.
resource "github_repository_ruleset" "delphi_ai_default_branch" {
  name        = "default branch"
  repository  = github_repository.delphi_ai.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # Admins may merge a PR without its review, but never push directly.
  bypass_actors {
    # The role has no actor ID; GitHub ignores one if set.
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

    # Not strict: the queue already tests each PR on top of the one ahead.
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
      merge_method                      = "MERGE"
      grouping_strategy                 = "ALLGREEN"
      max_entries_to_build              = 5
      min_entries_to_merge              = 1
      max_entries_to_merge              = 5
      min_entries_to_merge_wait_minutes = 0
      check_response_timeout_minutes    = 60
    }
  }
}

resource "github_repository_ruleset" "infrastructure_default_branch" {
  name        = "default branch"
  repository  = github_repository.infrastructure.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    # The role has no actor ID; GitHub ignores one if set.
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

    # Strict, so the plan a PR shows was made against the current main.
    required_status_checks {
      strict_required_status_checks_policy = true

      required_check {
        context = "plan"
      }
    }
  }
}
