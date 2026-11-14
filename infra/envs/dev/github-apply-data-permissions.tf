data "aws_caller_identity" "current" {}

# checkov:skip=CKV_AWS_289: Terraform must manage bucket and key policies. Scoped to sv-uploads-* buckets and keys of this account.
# checkov:skip=CKV_AWS_290: Write access is limited to sv-uploads-* buckets, sv-* tables and keys of this account.
data "aws_iam_policy_document" "apply_data_layer" {
  statement {
    sid = "ManageUploadsBuckets"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketVersioning",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:PutLifecycleConfiguration",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketTagging",
    ]
    resources = ["arn:aws:s3:::sv-uploads-*"]
  }

  statement {
    sid = "ManageTables"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:UpdateTable",
      "dynamodb:UpdateContinuousBackups",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
    ]
    resources = [
      "arn:aws:dynamodb:eu-south-2:${data.aws_caller_identity.current.account_id}:table/sv-*",
      "arn:aws:dynamodb:eu-south-2:${data.aws_caller_identity.current.account_id}:table/sv-*/index/*",
    ]
  }

  # kms:CreateKey cannot be limited to a resource, because the key does not exist yet.
  statement {
    sid       = "CreateKeys"
    actions   = ["kms:CreateKey"]
    resources = ["*"]
  }

  # Keys have random IDs, so they are limited by account and Region, and aliases by the sv- prefix.
  statement {
    sid = "ManageKeys"
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:UpdateAlias",
      "kms:EnableKeyRotation",
      "kms:DisableKeyRotation",
      "kms:EnableKey",
      "kms:DisableKey",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:PutKeyPolicy",
      "kms:UpdateKeyDescription",
      "kms:TagResource",
      "kms:UntagResource",
    ]
    resources = [
      "arn:aws:kms:eu-south-2:${data.aws_caller_identity.current.account_id}:key/*",
      "arn:aws:kms:eu-south-2:${data.aws_caller_identity.current.account_id}:alias/sv-*",
    ]
  }

  # DynamoDB needs a grant on the key when a table uses a customer managed key.
  statement {
    sid       = "DynamoDBUsesKey"
    actions   = ["kms:CreateGrant"]
    resources = ["arn:aws:kms:eu-south-2:${data.aws_caller_identity.current.account_id}:key/*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["dynamodb.eu-south-2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "apply_data_layer" {
  name   = "data-layer"
  role   = aws_iam_role.gha_terraform_apply.id
  policy = data.aws_iam_policy_document.apply_data_layer.json
}