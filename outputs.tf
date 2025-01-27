output "this" {
  value       = aws_db_instance.this
  description = "The created RDS instance."
  sensitive   = true
}

output "security_group" {
  value       = aws_security_group.this
  description = "The RDS security group."
}

output "secret_id" {
  value       = aws_secretsmanager_secret.this.id
  description = "The secret that contains the database master account password"
}
