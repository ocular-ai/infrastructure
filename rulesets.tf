locals {
  # The organization-admin role, in GitHub's ruleset actor IDs.
  organization_admin = 1
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
    actor_id    = local.organization_admin
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
    actor_id    = local.organization_admin
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

    # Strict, so a plan is never applied against a stale base.
    required_status_checks {
      strict_required_status_checks_policy = true

      required_check {
        context = "validate"
      }

      # The speculative plan Terraform Cloud's VCS integration posts.
      required_check {
        context = "Terraform Cloud/ocular-ai/infrastructure"
      }
    }
  }
}
