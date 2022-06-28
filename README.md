# AWS CodePipeline Project to deploy terraform templates

## Resources deployed by this manifest:

- Artifact S3 Bucket
- KMS Key for the Artifact S3 Bucket
- IAM Role for the CodePipeline Project.
- IAM Role for the CodeBuild Project.
- CodeBuil Projects.
- CodePipeline Projects.

### Deployment diagram:

![App Screenshot](images/Terraform-CodePipeline.drawio.png)

## Tested with: 

| Environment | Application | Version  |
| ----------------- |-----------|---------|
| WSL2 Ubuntu 20.04 | Terraform | v1.2.2  |

## Initialization How-To:
Located in the root directory, make the necessary changes in the variables.tf file and run "terraform init" to download the necessary modules and start the backend.

```bash
terraform init
```

## Deployment How-To:

Located in the root directory, make the necessary changes in the variables.tf file and run the manifests:

```bash
terraform apply
```
## Deployment How-To:

## Debugging / Troubleshooting:

#### **Debugging Tip #1**: 

#### **Known issue #1**: 
 - **Issue**: 
- **Cause**: 
- **Solution**: 


## Documentation:

- [EXAMPLE](URL)