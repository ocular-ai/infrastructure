# infrastructure

The ocular-ai organization's infrastructure as Terraform. Change a setting
here, not in a UI; the next plan reports anything changed by hand.

## Layout

Each directory is one Terraform root with its own HCP Terraform workspace,
state and credentials, so a bad apply in one cannot touch another.

| Directory | Workspace | Manages |
|-----------|-----------|---------|
| `github/` | `github` | Repositories, their rulesets, environments and Pages sites. |

Split a new root off when its resources need different credentials,
change on a different schedule, or belong to another environment. A root
reads another's outputs through the `tfe_outputs` data source rather than
sharing its state.

Inside a root:

| File | Holds |
|------|-------|
| `versions.tf` | The HCP Terraform workspace and the provider versions. |
| `providers.tf`, `variables.tf` | The providers and the credentials they take. |
| `imports.tf` | Imports of what existed before Terraform managed it; delete once applied. |

## How changes land

1. Open a PR. The `Plan` workflow checks formatting and validity, runs a
   speculative plan of every root in HCP Terraform, and posts each plan as
   a PR comment. Its `plan` check is required.
2. Read the plans, get a review, and merge.
3. The `Apply` workflow waits for approval in the `production`
   environment, then applies the roots one at a time.

Runs execute remotely in HCP Terraform, which holds each workspace's
provider credentials. GitHub holds only `TF_API_TOKEN`.

## Adding a root

1. Create its directory, with a `versions.tf` naming a new workspace.
2. Create the workspace with the CLI-driven workflow and add its variables.
3. Add the directory to the `matrix` of both workflows.

## Bootstrap

Done once, by an organization owner. The workflows cannot run the first
apply: they need the `production` environment and the infrastructure
repository's ruleset, which that apply creates.

1. **GitHub App.** Under the organization's *Settings → Developer settings
   → GitHub Apps*, create `ocular-ai-infrastructure`, with no webhook and
   these permissions:
   - Repository: *Administration*, *Contents*, *Environments*, *Metadata*,
     *Pages*: read and write.
   - Organization: *Administration*, *Members*: read and write.

   Generate a private key, then install the App on the organization for
   all repositories. Its ID is on the App's page, and the installation ID
   is the number at the end of the installation's URL.
2. **HCP Terraform.** In the `ocular_ai` HCP Terraform organization,
   create the `github` workspace with the *CLI-driven workflow* and remote
   execution. Under its *Variables*, add three Terraform variables:
   - `github_app_id`
   - `github_app_installation_id`
   - `github_app_pem_file`: the key's contents, marked sensitive.
3. **API token.** Create a team API token for the organization's owners
   team, and add it to this repository's Actions secrets as
   `TF_API_TOKEN`. An organization token cannot start runs.
4. **First apply.** Locally, `terraform login`, then in `github/` run
   `terraform init` and `terraform plan`. Check that it imports the
   existing repositories and Pages site and creates only the rulesets and
   the environment, then `terraform apply`.
5. **Classic protection.** `delphi.ai`'s `master` had classic branch
   protection before its ruleset. Once the ruleset is active, delete the
   classic rule under *Settings → Branches*. The ruleset covers it.

From then on, every change goes through a PR.
