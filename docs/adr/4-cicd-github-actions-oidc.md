# ADR 4: CI/CD with GitHub Actions and OIDC, one role per environment

## Status

Accepted (2026-11)

## Context

Terraform was run by hand from a developer machine. I wanted every change to be reviewed, checked and deployed the same way, without storing long-lived AWS access keys in GitHub. The repository is public, so workflow logs and pull request comments are visible to anyone.

## Decision

- **GitHub Actions with OIDC.** Workflows sign in to AWS by exchanging a short-lived GitHub token for temporary credentials. No AWS access keys are stored in GitHub.
- **Two roles per account** (`sv-dev` and `sv-prod`):
  - `gha-terraform-plan` is trusted only for pull request runs. It is read-only plus the state lock file.
  - `gha-terraform-apply` is trusted only for runs in the matching GitHub Environment (`dev` or `prod`). It can read the account and write its own state file.
- **Trust is tied to this repository.** The `sub` claim of the GitHub token contains numeric IDs for the owner and the repository (for example `repo:owner@ID/name@ID:pull_request`). My first trust policies used the plain `owner/name` form and every run was rejected, so the numeric form is required. Inspecting the real token claims in a temporary debug step found this.
- **GitHub Environments.** Both `dev` and `prod` deploy only from `main`. `prod` also requires a manual approval, and administrators cannot bypass it.
- **Required checks.** A branch ruleset on `main` requires `terraform` (format and validate), `checkov`, `plan-dev` and `plan-prod` before a merge. Infracost is not required because its workflow only runs when `infra/` changes.
- **IAM stays manual.** The OIDC provider and the pipeline roles are applied from a developer machine with SSO. The apply roles cannot change IAM, so the pipeline cannot give itself more permissions.
- **No profile in Terraform code.** The environment folders do not hard-code an AWS profile, so the same code runs locally (`AWS_PROFILE`) and in GitHub Actions.
- **Privacy in a public repo.** Role ARNs are marked `sensitive`, plan comments hide 12-digit account IDs, and the AWS credentials action masks the account ID in logs.
- **Maintenance.** Actions are pinned to a version, and Dependabot proposes updates weekly for Actions and Terraform providers.

## Consequences

- No long-lived AWS keys exist anywhere in GitHub.
- Dev deploys automatically after a merge. Prod waits for my approval.
- A broken format or a failing plan blocks the merge, as tested with a deliberately broken pull request.
- The apply roles cannot create resources yet. Permissions will be added per phase, only for the services that phase creates.
- The plan role uses `ReadOnlyAccess`, which is broader than strictly needed (for example it can read objects in other buckets of the account). It is acceptable for now and should be narrowed later.
- Changes to IAM resources fail in the pipeline with `AccessDenied` by design, and must be applied manually.
- GitHub Actions can run pull request code with the plan role. Keeping that role read-only limits the damage.
