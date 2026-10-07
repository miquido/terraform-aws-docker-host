variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID (region-specific)"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_public_keys" {
  description = "List of SSH public keys added to the ubuntu user's authorized_keys on the EC2 instance."
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  type = string
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "data_volume_size" {
  type    = number
  default = 20
}

variable "ssh_ip_range" {
  description = "CIDR allowed SSH access"
  type        = string
}

variable "domain" {
  description = "Base domain (e.g. dmc.example.com). Wildcard cert will be issued for *.domain."
  type        = string
}

variable "acme_email" {
  description = "Email for Let's Encrypt ACME registration"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
}

variable "oidc_jwks_url" {
  description = "JWKS URL for docker-compose-runner OIDC authentication"
  type        = string
}

variable "oidc_audience" {
  description = "Expected OIDC audience for docker-compose-runner"
  type        = string
}

variable "oidc_expected_subs" {
  description = "List of expected OIDC subjects for docker-compose-runner"
  type        = list(string)
}

variable "ip_allowlist" {
  description = "CIDR range allowed to access the docker-compose-runner endpoint"
  type        = string
}

variable "docker_compose_runner_image" {
  type    = string
  default = "ghcr.io/miquido/gitlab-docker-compose-host:v1.4.0"
}

variable "ecr_registry_url" {
  description = "ECR registry URL (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com). Leave empty to skip ECR setup."
  type        = string
  default     = ""
}

variable "use_spot" {
  description = "Use EC2 Spot instance (persistent, stop on interruption). Reduces cost ~70% for dev environments."
  type        = bool
  default     = false
}

variable "docker_prune_schedule" {
  description = "Cron schedule for Docker image pruning via Ofelia. Set to empty string to disable."
  type        = string
  default     = "0 3 * * *"
}

variable "walg_backup_retention_days" {
  description = "Number of days to retain WAL-G backups in S3 before automatic deletion."
  type        = number
  default     = 30
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  default     = 30
}

variable "enable_metrics" {
  description = "Ship Docker logs to CloudWatch Logs (awslogs driver) and Traefik metrics through the CloudWatch Agent."
  type        = bool
  default     = true
}

variable "enable_registry" {
  description = "Run the built-in docker registry on the host (registry.<domain>). Pair it with registry_htpasswd, since it has no authentication of its own."
  type        = bool
  default     = false
}

variable "registry_htpasswd" {
  description = "htpasswd entries (bcrypt, comma-separated for several users) protecting the built-in registry."
  type        = string
  sensitive   = true
  default     = ""
}

variable "registry_username" {
  description = "User the host logs in to the built-in registry with (must be one of registry_htpasswd's)."
  type        = string
  default     = ""
}

variable "registry_password" {
  description = "Password for registry_username."
  type        = string
  sensitive   = true
  default     = ""
}
