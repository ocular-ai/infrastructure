# infrastructure

The ocular-ai organization's GitHub settings as Terraform: its repositories,
their rulesets and their Pages sites. Change a setting here, not in the UI;
the next plan reports anything changed by hand.

## How changes land

1. Open a PR. Terraform Cloud's VCS integration posts a speculative plan as
   the `Terraform Cloud/ocular-ai/infrastructure` check, and the `validate`
   workflow checks formatting and validity.
2. Read the plan in the check's details.
3. Merge. Terraform Cloud plans `main` again and applies it.

The state lives in the `infrastructure` workspace of the `ocular-ai`
Terraform Cloud organization, never in this repository.

## Layout

| File | Holds |
|------|-------|
| `versions.tf` | The Terraform Cloud workspace and the provider version. |
| `providers.tf`, `variables.tf` | The GitHub provider, authenticated as a GitHub App. |
| `repositories.tf` | Each repository's settings, and Pages. |
| `rulesets.tf` | Branch rulesets: reviews, required checks, merge queues. |
| `imports.tf` | Imports of what existed before this repository; delete once applied. |

## Bootstrap

Done once, by an organization owner, before the first apply.

1. **GitHub App.** Under the organization's *Settings → Developer settings
   → GitHub Apps*, create `ocular-ai-infrastructure`, with no webhook and
   these permissions:
   - Repository: *Administration*, *Contents*, *Metadata*, *Pages*: read
     and write.
   - Organization: *Administration*, *Members*: read and write.

   Generate a private key, then install the App on the organization for
   all repositories. Its ID is on the App's page, and the installation ID
   is the number at the end of the installation's URL.
2. **Terraform Cloud.** In the `ocular-ai` organization, create the
   `infrastructure` workspace with the *Version control workflow*,
   connected to `ocular-ai/infrastructure` on `main`. Under its
   *Variables*, add three Terraform variables:
   - `github_app_id`
   - `github_app_installation_id`
   - `github_app_pem_file`: the key's contents, marked sensitive.
3. **First apply.** Queue a run, check that the plan imports the existing
   repositories and Pages site and creates only the rulesets, then apply.
4. **Classic protection.** `delphi.ai`'s `master` had classic branch
   protection before its ruleset. Once the ruleset is active, delete the
   classic rule under *Settings → Branches*. The ruleset covers it.
