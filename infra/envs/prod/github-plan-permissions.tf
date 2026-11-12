data "aws_iam_policy_document" "plan_state_access" {
  statement {
    sid       = "ListStateBucket"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::sv-tfstate-prod-safouan"]
  }

  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::sv-tfstate-prod-safouan/envs/prod/terraform.tfstate"]
  }

  statement {
    sid       = "StateLockFile"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::sv-tfstate-prod-safouan/envs/prod/terraform.tfstate.tflock"]
  }
}

resource "aws_iam_role_policy" "plan_state_access" {
  name   = "terraform-state-access"
  role   = aws_iam_role.gha_terraform_plan.id
  policy = data.aws_iam_policy_document.plan_state_access.json
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.gha_terraform_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}