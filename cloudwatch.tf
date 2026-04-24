resource "aws_cloudwatch_log_group" "docker" {
  name              = "/docker/${var.domain}"
  retention_in_days = var.cloudwatch_log_retention_days
}
