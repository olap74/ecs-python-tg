# FlaskApp

### Build with plain Terraform

This directory contains Terraform module which consolidates other modules to provide ability to deploy same solution without using of Teragrunt.

Deployment with plain Terraform a bit more complex than with Teragrunt. Follow the instruction below.

> *Remember that you should not create resourses with both solutions (plain Terraform and Terraform+Terragrunt) together. Both solution uses the same modules and resources will have the same names which will result an issue if you run deploy after it is deployed with another solution.*

### Deployment 

#### <u>Description</u>

This directory contains the next files: 

- `./config/buildspec.yml` - Codebuild pipeline for Application deployment with Terraform
- `./config/dev.tfvars` - Environment related variables
- `./config/secret.tfvars` - Contains sensitive data. Not present in the repo.
- `./modules/s3` - Terraform module for creating a state bucket
- `./main.tf` - Main Terraform file. Contains modules configuration.
- `./outputs.tf` - Contains Terraform outputs
- `./terraform.tf` - Terraform configuration file
- `./vars.tf` - Required variables

#### <u>Preparation</u>

First, you should add a [GitHub token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) to `./config/secret.tfvars`Create the file ad fill with the next content: 

```
github_oauth_token = "GITHUB_TOKEN"
```

Then you should verify variable values in `./config/dev.tfvars`file and you will be prepared for the next step.

#### <u>Terraform state bucket</u>

The next step means Terraform bucket creation. The main idea is next. First, you should create a bucket, then you should move your existing Terraform state to the bucket.

That means Terraform should create state file locally during bucket creation. Then state can be moved to a bucket. 

First, you need to update `./terraform.tf`file. You should comment out backend configuration. The `terraform.tf`file should look like: 

``` 
provider "aws" {
    region = var.aws_region
    profile = var.aws_profile
}

terraform {
  // backend "s3" {
  //   encrypt = true
  //   bucket  = "flaskapp-dev-eu-west-1"
  //   region  = "eu-west-1"
  //   key     = "state"
  // }
  required_providers {
    aws = {
      version = "~> 3.35"
    }
  }
}

```

**Do not delete these lines!** Just comment out. Save the file and run bucket creation:

```
terraform init
terraform plan -target=module.s3_terraform_state --var-file=./config/dev.tfvars
```

Then verify plan out and run:

```
terraform apply -target=module.s3_terraform_state --var-file=./config/dev.tfvars
```

And confirm apply.

The next step is copying state into created bucket. Terraform can do it itself, just uncomment lines you commented before bucket creation and run `terraform init`. Terraform returns the next message: 

```
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.
  
Do you want to copy existing state to the new backend?
Only 'yes' will be accepted to confirm.

  Enter a value: 
```

Type `yes`and state will be moved to the bucket.

After moving state to S3 you can delete directory `./terraform`, and files `terraform.state` and `terraform.state.backup`It is not required and will not be commited to repository, you can delete them just to be shure that remote state is used. 

#### <u>Infrastructure deployment</u>

Now everything is ready to deploy infrastructure. Run the next command: 

```
terraform plan --var-file=./config/dev.tfvars --var-file=./config/secret.tfvars
```

If plan creation succeeded, apply it:

```
terraform apply --var-file=./config/dev.tfvars --var-file=./config/secret.tfvars
```

Terraform will create the next resources:

- ECR repository
- Build an image and push it to a new repo
- ECS Cluster
- Codebuild job

When Terraform finish resources creation, you can commit updated code to "develop" branch and build will be started after a new commit pushed to git repo.

You can deploy infrastructure step by step. If you want to do it, you should use Terraform targeting. 

It can be done like this. First, ECR should be created:

```
terraform apply -target=module.ecr --var-file=./config/dev.tfvars
```

Then you should run initial image build:

```
terraform apply -target=module.init-build --var-file=./config/dev.tfvars
```

Then deploy ECS Cluster:

```
terraform apply -target=module.ecs-cluster --var-file=./config/dev.tfvars
```

And finally, create Codebuild job:

```
terraform apply -target=module.codebuild --var-file=./config/dev.tfvars --var-file=./config/secret.tfvars
```

Pay attention that secret.tfvars can be used for Codebuild module only, because GetHub token is used here.

#### <u>Destroying infrastructure</u>

If you run `terraform destroy --var-file=./config/dev.tfvars` it will fail because Terraform state bucket has deletion protection to prevent bucket deletion and loosing Terraform state as a result. 

So, you should run destroy for modules one by one in reverse order of deployment:

```
terraform destroy -target=module.codebuild --var-file=./config/dev.tfvars
terraform destroy -target=module.ecs-cluster --var-file=./config/dev.tfvars
terraform destroy -target=module.init-build --var-file=./config/dev.tfvars
terraform destroy -target=module.ecr --var-file=./config/dev.tfvars
```

S3 Bucket can be deleted manually using AWS console or AWS Cli. Or just leave it intact. If you want to deploy the application later, it will use it again. Even if you will use solution with Terragrunt, you leave this bucket because Terragrunt will create a different one.

Pay attention that running destroy for init-build module does not deletes any resources, but it should be executed to update Terraform state with information that it was destroyed. In case if you decide to deploy application again after destroy it will not run init-build if it was not destroyed because Terraform state will contain information that it was completed, even if initial image is not exists in ECR repo because it was deleted during ECR destruction.

