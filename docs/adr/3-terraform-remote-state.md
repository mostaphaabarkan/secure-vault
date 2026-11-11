# ADR 0003: Terraform remote state in S3 with native locking

- Status: Accepted
- Date: 2026-11-11

## Context

Terraform needs a place to store its state. A local state file is easy to lose, cannot be shared, and may contain sensitive values. The project uses separate AWS accounts for dev and prod, so state must also be isolated per account.

## Decision

- Use one S3 state bucket per account (`sv-dev` and `sv-prod`), created by a `bootstrap` Terraform configuration for each account. Each bootstrap starts with local state and is then migrated to its own bucket.
- Use S3 native locking (`use_lockfile = true`, Terraform 1.10 or later). No DynamoDB table.
- Enable versioning, Block Public Access (all four settings) and server-side encryption (SSE-S3) on the buckets.
- Add a bucket policy that denies requests that do not use TLS.
- Add a lifecycle rule that expires noncurrent state versions after 90 days.
- Set `prevent_destroy = true` on the state buckets.
- Apply the tags `Project`, `Environment`, `Owner` and `ManagedBy` through `default_tags` on the provider.
- Run pre-commit hooks (`terraform fmt`, `terraform validate`, Checkov) before every commit.
- Accept four Checkov findings on the state buckets, each documented with a `#checkov:skip` comment in the code:
  - `CKV_AWS_18` (access logging): a central logging bucket is planned for phase 3.
  - `CKV_AWS_144` (cross-region replication): planned for phase 9 for data buckets.
  - `CKV_AWS_145` (KMS encryption): SSE-S3 is enough for a state bucket and KMS adds cost and complexity.
  - `CKV2_AWS_62` (event notifications): nothing consumes events from the state bucket.

## Consequences

- Dev and prod state are isolated, so a mistake in one account cannot overwrite the other.
- Versioning allows recovery of a previous state file.
- No DynamoDB table to pay for or maintain.
- Prod state is not replicated to another region. This is a conscious trade-off for this project. A production environment in a company would normally replicate it. It will be reviewed in phase 9.
- Access logging is missing until the central logging bucket exists. The `CKV_AWS_18` skip must be removed in phase 3.
- Every new Terraform folder must be added to the pre-commit validate script and to the Dependabot configuration.
- Account IDs and the access portal URL are not committed to the repository.