# terraform-aws-gcc-tfbackend

Tired of manually creating and managing S3 backends for your Terraform projects? Look no further!

## What does this do?

This project:

1. creates resources for a Terraform backend on S3 / DynamoDB; and
2. migrates its own state to the `default` workspace.

# Quickstart Guide

## 0. Authentication

First, populate your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

## 1. Create the backend configuration file

Configure your project's `backend.tfvars` file

```terraform
Agency-Code  = "example"
Project-Code = "demo"
Environment  = "dev"
Zone         = "dz"
Tier         = "na"
```

## 2. Switch to remote backend

It's time to make the switch to remote state!

```shell
make switch-remote
```

```
Selecting backend: REMOTE

terraform init -force-copy --backend-config=backend.tfbackend
Initializing modules...

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.65.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

... output redacted ...

```

That's it! Copy the generated `backend.tfbackend` file to your project folder, or export it as an artifact.

---

# Advanced Usage

## Switching to local state

```shell
make switch-local
```

## Backing up the state file

For peace of mind, the current state can be easily exported to `backup.tfstate`.

```shell
make backup
```

## Synchronising with an existing remote backend

0. Start with a clean working directory.

```shell
make distclean
```

1. Synchronise with the backend described in the `backend.tfbackend` file.

```shell
make sync
```

## Destroying the remote backend

If you want to tear down the backend, follow these steps.

0. Ensure the default workspace is the only workspace using the backend (very, very important).

```shell
terraform workspace list
```

1. Destroy the backend infrastructure (this action is IRREVERSIBLE).

```shell
make destroy
```

2. (Optional) Clean the working directory.

```shell
make distclean
```

---

# Important Notes

- The S3 backend will _always_ be created in the default workspace.
- Create a workspace for every `<project>-<environment>` combination. (see
  also: [One workspace per environment per terraform configuration](https://www.terraform.io/docs/cloud/guides/recommended-practices/part1.html#one-workspace-per-environment-per-terraform-configuration))

---

# Documentation

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| Agency-Code | The agency initials | `string` | n/a | yes |
| Environment | The environment (e.g. tXX, dev, stg, uat, prd) | `string` | n/a | yes |
| Project-Code | The project code | `string` | n/a | yes |
| Tier | Tier identifier (e.g. web, gut, app, it, db, svc, na) | `string` | `null` | no |
| Zone | The zone (e.g. iz, ez, mz ,dz) | `string` | `null` | no |
| bucket | Name of the S3 Bucket | `string` | `""` | no |
| dynamodb\_table | Name of the DynamoDB table | `string` | `""` | no |
| encrypt | Encrypt the contents of the bucket | `bool` | `true` | no |
| key | Key to use for the Terraform state file | `string` | `"terraform.tfstate"` | no |
| prevent\_destroy | Prevent accidental destruction of the Terraform state bucket | `bool` | `true` | no |
| region | AWS Region selection | `string` | `"ap-southeast-1"` | no |
| versioning | Enable versioning on the bucket | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | Name of the S3 Bucket |
| dynamodb\_table | Name of the DynamoDB table |
| encrypt | Encrypt the contents of the bucket |
| key | Key to use for the Terraform state file |
| region | AWS Region selection |

