# ADR 6: Authentication with Amazon Cognito

## Status

Accepted (2026-11)

## Context

Users must sign in before they can upload or see files. The vault is private, so only invited people should have access, and every account needs a second factor. The pipeline must not be able to create users or set passwords.

## Decision

- **One user pool per environment** (`sv-users-<env>`), email as username, email verified.
- **Invite-only.** Self sign-up is disabled, and only an administrator creates users.
- **MFA is mandatory with an authenticator app (TOTP).** SMS is not used, because it costs money and is weaker.
- **Password policy:** at least 12 characters with upper case, lower case, number and symbol.
- **Feature plan Lite.** It covers TOTP, the OAuth 2.0 server and the classic hosted UI. Essentials is the default plan for new pools and would add managed login, email MFA and passkeys, which this project does not need. Pricing for Spain was not verified, and with a handful of users the cost is negligible.
- **Public app client** without a secret: authorization code grant, implicit flow disabled, scopes `openid`, `email` and `profile`, only SRP and refresh-token auth flows, short ID and access tokens (60 minutes), token revocation on, and user-existence errors hidden.
- **Groups** `admins` and `users`.
- **Pipeline permissions:** the apply role can create the pool, client, domain and groups of this account and Region. It has no user or password actions, so only an administrator with SSO can create users. They are applied manually with SSO, because the apply role cannot change IAM.

## Consequences

- Cognito cannot enforce PKCE on the server for a public client, so the frontend must use it.
- `cognito-idp:CreateUserPool` cannot be limited to a resource, so it is the one action allowed on `*`. The matching Checkov rule is skipped with a reason in the code.
- The callback URL points to localhost in both environments until phase 10 adds the real frontend URL. It must be replaced then, especially in prod.
- Invitation emails use the default Cognito sender, which has a low daily limit. It is enough for this project, and SES would be needed for real use.
- Deleting a pool deletes its users, so the pool has `prevent_destroy`, and prod also has deletion protection.
