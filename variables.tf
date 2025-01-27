variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gibibytes."
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  default     = false
}

variable "backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled."
  default     = "00:00-01:00"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance."
  default     = null

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.db_name))
    error_message = "DBName must begin with a letter and contain only alphanumeric characters."
  }
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "A list of VPC subnet IDs."
}

variable "deletion_protection" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true."
  default     = true
}

variable "engine" {
  type        = string
  description = "The database engine to use."
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "The engine must be either 'postgres' or 'mysql'."
  }
}

variable "engine_version" {
  type        = string
  description = "The engine version to use. Latest if not specified."
  default     = null
}

variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance."
  default     = "db.t3.micro"
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in."
  default     = "Wed:01:00-Wed:04:00"
}

variable "multi_az" {
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ."
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created."
  default     = false
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted."
  default     = true
}

variable "username" {
  type        = string
  description = "Username for the master DB user."
  default     = "master"
}

variable "password_length" {
  type        = number
  description = "Length of the password for the master DB user"
  default     = 25
}

variable "data_classification_tag" {
  type        = string
  description = "The value to be passed to the tag Classification for data Classification purposes."
  default     = "Confidential"
}
