variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = ""
}

variable "code_connection" {
  type    = string
  default = ""
}

variable "repository_id" {
  type    = string
  default = ""
}

variable "repository_branch" {
  type    = string
  default = ""
}

variable "terraform_version" {
  type    = string
  default = "1.2.2"
}

variable "compute_type" {
  description = "The compute size that CodeBuild will use to execute the build" # Ref: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition = (
      var.compute_type == "BUILD_GENERAL1_SMALL" ||
      var.compute_type == "BUILD_GENERAL1_MEDIUM" ||
      var.compute_type == "BUILD_GENERAL1_LARGE" ||
      var.compute_type == "BUILD_GENERAL1_2XLARGE"
    )
    error_message = "The value must be one of the followings: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE"
  }
}

/* Tags Variables */
#Use: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-place-holder" }, )
variable "project-tags" {
  type = map(string)
  default = {
    service     = "Terraform-CodePipeline",
    environment = "POC"
    DeployedBy  = "example@mail.com"
  }
}

#Use: tags = { Name = "${var.name-prefix}-lambda" }
variable "name-prefix" {
  type    = string
  default = "terraform"
}

