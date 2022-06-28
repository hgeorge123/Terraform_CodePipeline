/*
Role: Terraform CodePipeline
Description: Used by the CodePipeline Project
*/

data "aws_iam_policy_document" "codepipeline_policy_source" {
  statement {
    sid    = "AllowPassingIAMRoles"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudwatchPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodestarPolicy"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["${var.code_connection}"]
  }

  statement {
    sid    = "CodeBuildPolicy"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ArtifactPolicy"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.artifact.arn}",
      "${aws_s3_bucket.artifact.arn}/*",
    ]
  }

  statement {
    sid    = "S3Policy"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoPolicy"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMSKeyPolicy"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["${aws_kms_key.artifact.arn}"]
  }
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    sid    = "CodeStartAssumeRole"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = lower("${var.name-prefix}-codepipeline-policy")
  path        = "/"
  description = "CodePipeline Policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy_source.json
  tags        = { Name = "${var.name-prefix}-codepipeline-policy" }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = lower("${var.name-prefix}-codepipeline-role")
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
  tags               = { Name = "${var.name-prefix}-codepipeline-role" }
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

/*
Role: Terraform CodeBuild
Description: Used by the CodeBuild Project
*/
data "aws_iam_policy_document" "buil_policy_source" {
  statement {
    sid    = "CloudwatchPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowPassingIAMRoles"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodestarPolicy"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["${var.code_connection}"]
  }

  statement {
    sid    = "S3Policy"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoPolicy"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMSKeyPolicy"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    sid    = "CodeBuildAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }

  statement {
    sid    = "CrossAccountAssumeRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${lower("${var.name-prefix}-apply-role")}"
        ]
    }
    actions = ["sts:AssumeRole"]
  }

}

resource "aws_iam_policy" "codebuild_policy" {
  name        = lower("${var.name-prefix}-codebuild-policy")
  path        = "/"
  description = "CodePipeline Policy"
  policy      = data.aws_iam_policy_document.buil_policy_source.json
  tags        = { Name = "${var.name-prefix}-codebuild-policy" }
}

resource "aws_iam_role" "codebuild_role" {
  name               = lower("${var.name-prefix}-codebuild-role")
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
  tags               = { Name = "${var.name-prefix}-codebuild-role" }
}

resource "aws_iam_role_policy_attachment" "build_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

/*
Role: Terraform Apply
Description: This is the role that the terraforming provider assumes to deploy the resources.
*/
data "aws_iam_policy_document" "terraform_apply_assume_role_policy" {
  statement {
    sid    = "TerraformApplyPolicy"
    effect = "Allow"
    principals {
      type = "AWS"
      #identifiers = ["*"]
      identifiers = [
        "${aws_iam_role.codepipeline_role.arn}",
        "${aws_iam_role.codebuild_role.arn}"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "terraform_apply_role" {
  name                = lower("${var.name-prefix}-apply-role")
  assume_role_policy  = data.aws_iam_policy_document.terraform_apply_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  tags                = { Name = "${var.name-prefix}-apply-role" }
}

#################
# TO-DO: Fix Circular dependency whit bash: https://docs.aws.amazon.com/cli/latest/reference/iam/update-assume-role-policy.html
#################