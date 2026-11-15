# Reuses data.aws_caller_identity.current from github-apply-data-permissions.tf

data "aws_iam_policy_document" "uploads_key" {
  #checkov:skip=CKV_AWS_109:KMS key policy where Resource * means this key only. The account root statement delegates access to IAM, the AWS default pattern. See ADR 5.
  #checkov:skip=CKV_AWS_111:KMS key policy where Resource * means this key only. The account root statement delegates access to IAM, the AWS default pattern. See ADR 5.
  #checkov:skip=CKV_AWS_356:KMS key policy where Resource * means this key only. The account root statement delegates access to IAM, the AWS default pattern. See ADR 5.
  # Standard statement: access to the key is then controlled by IAM policies.
  # The pipeline role has no kms:Decrypt in its policies, so it cannot read data.
  statement {
    sid       = "EnableIAMPolicies"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "uploads" {
  description             = "Encrypts secure-vault uploads and file metadata"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.uploads_key.json

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "uploads" {
  name          = "alias/sv-uploads"
  target_key_id = aws_kms_key.uploads.key_id
}

output "uploads_key_arn" {
  value     = aws_kms_key.uploads.arn
  sensitive = true
}
