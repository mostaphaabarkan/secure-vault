# secure-vault

Serverless secure file vault on AWS with malware scanning, encryption (KMS), auto-remediation, cross-region replication and a React dashboard. Built with Terraform and GitHub Actions.

## Terraform

Infrastructure is managed with Terraform (1.10 or later). State is stored remotely in S3 with native locking, one bucket per account. See [ADR 0003](docs/adr/3-terraform-remote-state.md).

### Structure

| Folder                                | Purpose                                      |
| ------------------------------------- | -------------------------------------------- |
| `infra/bootstrap/`                    | Creates the state bucket in the dev account  |
| `infra/bootstrap-prod/`               | Creates the state bucket in the prod account |
| `infra/envs/dev/`, `infra/envs/prod/` | Environment infrastructure (empty for now)   |
| `infra/modules/`                      | Reusable modules (empty for now)             |

### Prerequisites

- Terraform 1.10 or later
- AWS CLI with SSO profiles `sv-dev` and `sv-prod`
- Python and `pre-commit`

### Run

Sign in first. SSO sessions expire, so repeat this when you see a credentials error:

```powershell
aws sso login --profile sv-dev
aws sso login --profile sv-prod
```

Then run Terraform in each folder:

```powershell
terraform -chdir=infra/bootstrap init
terraform -chdir=infra/bootstrap plan

terraform -chdir=infra/bootstrap-prod init
terraform -chdir=infra/bootstrap-prod plan
```

### First-time bootstrap

The state bucket cannot store its own state before it exists. On a new account:

1. Create the bucket with local state (no backend block yet).
2. Add the `backend "s3"` block with `use_lockfile = true`.
3. Run `terraform init -migrate-state` to move the local state into the bucket.
4. Delete the local `terraform.tfstate` files.

### Checks before every commit

```powershell
pre-commit install
pre-commit run --all-files
```

Hooks: `terraform fmt`, `terraform validate` and Checkov. Accepted Checkov findings are documented in the code with `#checkov:skip` and listed in ADR 0003.

### Cost and updates

- Resources are tagged with `Project`, `Environment`, `Owner` and `ManagedBy` through `default_tags`.
- Infracost comments the cost estimate on Pull Requests that change `infra/`. It needs the `INFRACOST_API_KEY` repository secret.
- Dependabot checks Terraform providers and GitHub Actions weekly.
