/*
category: Possible values are Approval, Build, Deploy, Invoke, Source and Test.
provider: Ref.: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference.html
*/
resource "aws_codepipeline" "tf_codepipeline" {
  name     = "tf-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_code"]

      configuration = {
        ConnectionArn        = var.code_connection
        FullRepositoryId     = var.repository_id
        BranchName           = var.repository_branch
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Validate"

    action {
      name            = "Validate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.validate.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ENVIRONMENT"
            value = "dev"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_VERSION"
            value = "1.2.2"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_APPLY_ROLE_ARN"
            value = "${aws_iam_role.terraform_apply_role.arn}"
            type  = "PLAINTEXT"
          },
        ])
      }
    }
  }

  stage {
    name = "DeployToDev"

    action {
      name            = "DevPlan"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"
      run_order       = 1

      configuration = {
        ProjectName = aws_codebuild_project.plan.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ENVIRONMENT"
            value = "dev"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_VERSION"
            value = "1.2.2"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_APPLY_ROLE_ARN"
            value = "${aws_iam_role.terraform_apply_role.arn}"
            type  = "PLAINTEXT"
          },
        ])
      }
    }

    action {
      name      = "DevApproval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2

      configuration = {
        #NotificationArn    = "..."
        CustomData = "By approving this step, you will apply the terraform manifest in the DEV Account."
        #ExternalEntityLink = "..."
      }
    }

    action {
      name            = "DevApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"
      run_order       = 3

      configuration = {
        ProjectName = aws_codebuild_project.apply.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ENVIRONMENT"
            value = "dev"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_VERSION"
            value = "1.2.2"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_APPLY_ROLE_ARN"
            value = "${aws_iam_role.terraform_apply_role.arn}"
            type  = "PLAINTEXT"
          },
        ])
      }
    }

    action {
      name      = "DestroyApproval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 4

      configuration = {
        CustomData = "By approving this step, you will DESTROY all resources deployed by terraform in the previous step."
      }
    }

    action {
      name            = "DevDestroy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"
      run_order       = 5

      configuration = {
        ProjectName = aws_codebuild_project.destroy.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ENVIRONMENT"
            value = "dev"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_VERSION"
            value = "1.2.2"
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_APPLY_ROLE_ARN"
            value = "${aws_iam_role.terraform_apply_role.arn}"
            type  = "PLAINTEXT"
          },
        ])
      }
    }
  }
}