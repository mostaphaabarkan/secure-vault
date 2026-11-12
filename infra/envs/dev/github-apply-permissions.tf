data "aws_iam_policy_document" "apply_state_access" {
  statement {
    sid       = "ListStateBucket"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::sv-tfstate-dev-safouan"]
  }

  statement {
    sid       = "ReadWriteState"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::sv-tfstate-dev-safouan/envs/dev/terraform.tfstate"]
  }

  statement {
    sid       = "StateLockFile"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::sv-tfstate-dev-safouan/envs/dev/terraform.tfstate.tflock"]
  }
}

resource "aws_iam_role_policy" "apply_state_access" {
  name   = "terraform-state-access"
  role   = aws_iam_role.gha_terraform_apply.id
  policy = data.aws_iam_policy_document.apply_state_access.json
}

resource "aws_iam_role_policy_attachment" "apply_readonly" {
  role       = aws_iam_role.gha_terraform_apply.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}