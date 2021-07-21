# FlaskApp

This repository contains a "FlaskApp", which is a small containerized application written with Python 3 Flask. This application can be deployed to AWS Elastic Container service with Terraform solution, which is also included. 

#### Tools versions:
- Terraform - 0.14.7
- Terragrunt - 0.28.7
- AWS Cli - 2.0.42

## Description

The repo contains the next components:
- Application itself
- Terragrunt deployment configuration
- Terraform modules
	- Cluster - Creates a ECS Cluster and related services
	- Codebuild - Creates an AWS Codebuild job which starts automatically when code pushed to "develop" branch
	- ECR - Creates an Elastic Container repository
	- Init-Build - Builds and deploys initial image to ECR when new repository is created

## Folders and Files

- /app - Main Application folder
- /providers - Terragrunt directory
    - ./dev - DEV environment configuration
        - ./codebuild - Terragrunt configuration for "codebuild" module
	    - ./ecr - Terragrunt configuration for "ecr" module
	    - ./ecs-cluster - Terragrunt configuration for "cluster" module
	    - ./init-build - Terragrunt configuration for "init-build" module
	    - ./buildspec.yml - Build SPEC for AWS Codebuild
	    - ./terragrunt.hcl - Main Terragrunt configuration file for "DEV" environment. Contains variable values.
	    - ./secrets.hcl - Contains required parameters. File is not in repo because it is added to .gitignore. Should be created manually.
- /modules - Terraform modules

## Configuration

Main configuration files are the next:

/providers/dev/terragrunt.hcl - Contains main variables for Terragrunt & Terraform:
- remote_state_bucket - S3 bucket for Terraform states
- envorinment - Environment name (dev, prod, etc)
- app_name - Name of Application (will be used for naming AWS resources)
- image_tag - Default value for Docker image tag. Will be used for initial build
- repo_url - GitHub repo URL
- aws_profile - The name of [AWS Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
- aws_account - AWS Account ID
- aws_region - AWS Region for creating resources
- branch_pattern - Which branch changes should webhook watch on (e.g.: "^refs/heads/develop$")
- git_trigger_event - Event for [git webhook](https://docs.aws.amazon.com/codebuild/latest/APIReference/API_WebhookFilter.html) 

You can set variable value during terragrunt run to override configuration. For example:

`terragrunt apply -var="app_name=MY_VALUE"`

/providers/dev/buildspec.yml - Pipeline file for AWS Codebuild. 

## Deployment

### Preparation

 - Install the required versions of Terragrunt and Terraform 
 - Configure AWS Cli for your account (see [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html))
 - Download the repo content
 - Edit configuration files described above
 - Obtaint [GitHub token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)
 - Create "secrets.hcl" file and add required variables:

`inputs = {
  remote_state_bucket = "terraform-nodeapp-ecs"
  environment = "dev"
  app_name = "flaskapp"
  image_tag = "0.0.1"
  repo_url = "https://github.com/olap74/ecs-python-tg"
  branch_pattern = "^refs/heads/develop$"
  git_trigger_event = "PUSH"
  aws_profile = "YOUR LOCAL PROFILE NAME"
  aws_account = "AWS ACCOUNT ID"
  aws_region = "AWS REgION"
  github_oauth_token = "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"
}
`

### One command deployment

 - Go to the /providers/dev directory and run:

`terragrunt run-all init`

- Then...

`terragrunt run-all plan`

- And if there is no issues in generated plan:

`terragrunt run-all apply`

### Step by step deployment

Step by step deployment should be done in the next order:

1. ECR creation (`providers/dev/ecr`)
2. Initial build (`providers/dev/init-build`)
3. Cluster creation (`providers/dev/ecs-cluster`)
4. Codebuild job setup (`providers/dev/codebuild`)

Go to each folder one by one and run:

`terragrunt plan`

- When plan is completed run:

`terragrunt apply`

- Go to the next directory when deployment completed. 

When resources creation is finished you can push a new version to "develop" branch of the repo you described in `env.hcl` file to initiate a new build 

### Destroy infrastructure

You can destroy everything you deployed with the next command which should be executed in `dev/` directory:

`terraform run-all destroy`

Or you can destroy components step by step in reverse order from deployment. Go to the appropriate directory and run:

`terragrunt destroy`   
