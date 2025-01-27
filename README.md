# simple-db-module

Simple terraform module to create a Postgres/MySQL database on AWS.

As it's only for a code review, I didn't have the time to test it in an AWS lab, it surely needs some debugging.

# Description

## Variables

I tried to keep the module simple as I don't know the client's requirements, we should keep something light and improve the module when new feature flags are required. Doing so, we will keep a module easily readable and thus, maintainable.

### Sizing, HA, and Security

- Variables like allocated_storage, instance_class, and multi_az ensure the module scales to different workloads and offers high availability by default.
- Encryption (storage_encrypted) and deletion protection (deletion_protection) are enabled by default for secure and resilient deployments.

### Flexibility

- Inputs such as db_name, engine, and engine_version allow customization for specific database engines and configurations.
- Defaults like backup_window and maintenance_window are set to common operational standards, reducing user setup effort.

### Validation and Defaults

Input validation (e.g., db_name regex, engine whitelist) prevents configuration errors.

### Terraform Best Practices

- This module encapsulates all necessary resources for creating an RDS instance, enabling reuse and simplified management.
- Stored the terraform state of the example in a s3 bucket.
- Kept a consistent and explicit naming convention.
- I based the code and AWS resources names (secrets for example) on the use of terraform workspace (such as **staging**, **preproduction**, **production**) to provide an explicit context when navigating the console.
- Avoided redundancy in resources names (ie things such as **resource "aws_db_subnet_group" "subnet_group_1"**).
- Input Validation: Enforces valid configurations, reducing deployment errors.
- Version Pinning: Providers are version-locked (aws ~> 5.0, random ~> 3.1) to ensure compatibility and prevent breaking changes.
- State Management: Outputs like secret_id and security_group provide necessary details while keeping sensitive data like passwords securely managed in AWS Secrets Manager.
- Tagging: Supports tagging (data_classification_tag) for governance and cost management.
- Also added a small gitlab-ci file to initialize a real one that could be done.

# Usage
```
module "rds" {
  source = "git::git@github.com/DuncanGold/simple-db-module.git"

  allocated_storage         = 20
  db_name                   = "my_db"
  engine                    = "postgres"
  engine_version            = "13.4"
  db_parameter_group_family = "postgres13"
  db_subnet_ids             = data.aws_subnets.this.ids
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in gibibytes. | `number` | n/a | yes |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled. | `string` | `"00:00-01:00"` | no |
| <a name="input_data_classification_tag"></a> [data\_classification\_tag](#input\_data\_classification\_tag) | The value to be passed to the tag Classification for data Classification purposes. | `string` | `"Confidential"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance. | `string` | `null` | no |
| <a name="input_db_subnet_ids"></a> [db\_subnet\_ids](#input\_db\_subnet\_ids) | A list of VPC subnet IDs. | `list(string)` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use. | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version to use. Latest if not specified. | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The instance type of the RDS instance. | `string` | `"db.t3.micro"` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The window to perform maintenance in. | `string` | `"Wed:01:00-Wed:04:00"` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies if the RDS instance is multi-AZ. | `bool` | `true` | no |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Length of the password for the master DB user | `number` | `25` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. | `bool` | `false` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB instance is encrypted. | `bool` | `true` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for the master DB user. | `string` | `"master"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | The secret that contains the database master account password |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | The RDS security group. |
| <a name="output_this"></a> [this](#output\_this) | The created RDS instance. |
<!-- END_TF_DOCS -->