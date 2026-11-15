# ADR 5: Data layer with an encrypted uploads bucket and a metadata table

## Status

Accepted (2026-11)

## Context

The vault needs a place to store uploaded files and a place to track their metadata and scan status. Files are sensitive, so encryption, versioning and no public access are required from the start. Infrastructure is deployed by the pipeline, which has limited permissions.

## Decision

- **One KMS key per environment** (customer managed, rotation on, alias `alias/sv-uploads`). It encrypts the uploads bucket and the table.
- **One uploads bucket per environment**, named `sv-uploads-<env>-safouan`: Block Public Access on all four settings, versioning, default SSE-KMS with a bucket key, ACLs disabled (bucket owner enforced), a lifecycle rule for old versions (90 days) and incomplete multipart uploads (7 days), and `prevent_destroy`.
- **Bucket policy** denies requests without TLS and denies uploads that declare an encryption other than KMS. Uploads that declare nothing are still encrypted with KMS by the bucket default.
- **One DynamoDB table per environment** (`sv-files-<env>`), on-demand billing, partition key `owner_id` and sort key `file_id`, encrypted with the KMS key, with point-in-time recovery. Deletion protection is on in prod.
- **Pipeline permissions** for the apply role are limited to S3 buckets named `sv-uploads-*`, DynamoDB tables named `sv-*` and KMS actions in this account and Region. They are applied manually with SSO, because the apply role cannot change IAM.

## Consequences

- The apply role cannot read or decrypt stored files. It has no `kms:Decrypt` and no object access.
- `kms:CreateKey` cannot be limited to a resource, and keys have random IDs, so KMS actions are limited by account and Region only. `kms:PutKeyPolicy` would let the role change who can use a key. This is accepted, and the protection of `main` and the manual approval of prod are the safeguards.
- The key policy gives the account root `kms:*`, which is the AWS default pattern and delegates access to IAM. Checkov rules CKV_AWS_109, CKV_AWS_111 and CKV_AWS_356 flag it, so they are skipped on that policy with a reason in the code. Any IAM identity of the account with `kms:Decrypt` can use the key.
- Checkov rules CKV_AWS_18 (access logging), CKV_AWS_144 (cross-region replication) and CKV2_AWS_62 (event notifications) are skipped on the uploads bucket, because they are planned for later phases.
- Each customer managed key costs about $1 per month, so the data layer costs about $2 per month in total for two environments. Prices were not verified for Spain.
