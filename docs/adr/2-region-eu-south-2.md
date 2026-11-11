# ADR 0002: Use IAM Identity Center (SSO) instead of IAM users

- Status: Accepted
- Date: 2026-11-11

## Context

The project uses four AWS accounts under AWS Organizations. Managing separate IAM users with passwords and access keys in each account is hard to secure and audit, and long-lived keys are a common source of leaks.

## Decision

- Use AWS IAM Identity Center with the built-in Identity Center directory as identity source.
- Require MFA (authenticator app) at every sign-in.
- Create groups `Admins` and `ReadOnly`, and permission sets `AdministratorAccess` and `ReadOnlyAccess` with a 4-hour session.
- Assign `Admins` to the management account, `sv-dev`, `sv-prod` and `sv-security`.
- Use the AWS CLI through `aws configure sso` profiles. No IAM users and no access keys in any account.
- The root user is used only for emergencies and has MFA and no access keys.

## Consequences

- Credentials are temporary and tied to MFA.
- `AdministratorAccess` is temporary for the setup phase. It will be replaced by least-privilege permission sets later.
- `ReadOnlyAccess` can read S3 object contents. A stricter custom permission set will be needed for the vault buckets.
- Every session must be refreshed with `aws sso login` after it expires.
- The access portal URL and account IDs are not committed to the repository.
