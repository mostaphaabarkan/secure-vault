# Reuses data.aws_caller_identity.current from github-apply-data-permissions.tf

data "aws_iam_policy_document" "apply_cognito" {
  #checkov:skip=CKV_AWS_356:cognito-idp:CreateUserPool cannot be limited to a resource, because the pool does not exist yet. Every other action is limited to user pools of this account and Region.

  statement {
    sid       = "CreateUserPools"
    actions   = ["cognito-idp:CreateUserPool"]
    resources = ["*"]
  }

  statement {
    sid = "ManageUserPools"
    actions = [
      "cognito-idp:DeleteUserPool",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:SetUserPoolMfaConfig",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:UpdateUserPoolClient",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:CreateUserPoolDomain",
      "cognito-idp:UpdateUserPoolDomain",
      "cognito-idp:DeleteUserPoolDomain",
      "cognito-idp:CreateGroup",
      "cognito-idp:UpdateGroup",
      "cognito-idp:DeleteGroup",
      "cognito-idp:TagResource",
      "cognito-idp:UntagResource",
    ]
    resources = [
      "arn:aws:cognito-idp:eu-south-2:${data.aws_caller_identity.current.account_id}:userpool/*",
    ]
  }
}

resource "aws_iam_role_policy" "apply_cognito" {
  name   = "cognito"
  role   = aws_iam_role.gha_terraform_apply.id
  policy = data.aws_iam_policy_document.apply_cognito.json
}