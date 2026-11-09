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
  default = "ghcr.io/miquido/gitlab-docker-compose-host:v1.4.2"
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
  description = "Run a docker registry on the host (registry.<domain>) instead of ECR, protected with basic auth. Credentials are generated unless registry_username/registry_password/registry_htpasswd are given; read them from the registry_* outputs."
  type        = bool
  default     = false
}

variable "registry_htpasswd" {
  description = "Override: htpasswd entries (bcrypt, comma-separated) for the built-in registry. Default: one entry for registry_username with a generated password."
  type        = string
  sensitive   = true
  default     = ""
}

variable "registry_username" {
  description = "Override: user of the built-in registry (and the one the host logs in with). Default: ci."
  type        = string
  default     = ""
}

variable "registry_password" {
  description = "Override: password for registry_username. Default: generated (see the registry_password output)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_apex_record" {
  description = "Create the A record for the apex of domain. Set to false to leave the apex pointing elsewhere (e.g. while migrating a live hostname onto this host: test it via /etc/hosts, then switch the record). The wildcard record, and with it docker.<domain>, is always created."
  type        = bool
  default     = true
}

variable "postgres_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach port 5432 (Traefik's TLS-routed Postgres entrypoint). Set to [] when no Postgres is published through Traefik."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ebs_snapshots" {
  description = "Take daily EBS snapshots of the data volume with Data Lifecycle Manager."
  type        = bool
  default     = true
}

variable "ebs_snapshot_retention_count" {
  description = "Number of daily data volume snapshots to keep."
  type        = number
  default     = 14
}

variable "ebs_snapshot_time" {
  description = "UTC time (HH:MM) of the daily data volume snapshot."
  type        = string
  default     = "23:45"
}

variable "data_volume_snapshot_id" {
  description = "Snapshot to create the data volume from, e.g. to restore after losing the host. Only read when the volume is created (`tofu apply -replace=...aws_ebs_volume.data`); changing it on an existing volume does nothing."
  type        = string
  default     = null
}

variable "walg_bucket_versioning" {
  description = "Keep object versions in the WAL-G bucket, so an overwritten or deleted backup/WAL object can be recovered for walg_noncurrent_version_retention_days."
  type        = bool
  default     = true
}

variable "walg_noncurrent_version_retention_days" {
  description = "Days to keep noncurrent versions (overwritten or deleted objects) of the WAL-G bucket. Only has an effect with walg_bucket_versioning."
  type        = number
  default     = 14
}

variable "enable_autoheal" {
  description = "Run willfarrell/autoheal (multi-arch, runs on Graviton), which restarts containers that Docker reports as `unhealthy`. Opt-in per container: only those with the label `autoheal=true` and a HEALTHCHECK are touched, so enabling it changes nothing until a project labels a container. It mounts the Docker socket, like the runner."
  type        = bool
  default     = true
}

variable "swap_size_gb" {
  description = "Size in GB of a swap file on the root volume, created at first boot. 0 disables it. Only a new instance gets it (user_data is not re-applied to an existing one)."
  type        = number
  default     = 2
}

variable "swappiness" {
  description = "vm.swappiness when swap_size_gb is set. A low value keeps the hot working set in RAM and moves only cold pages out."
  type        = number
  default     = 20
}

variable "walg_replication_destination_bucket_arn" {
  description = "ARN of a bucket (normally in a dedicated backup account) to replicate the WAL-G bucket into, one-way and without deletions. The destination must be versioned and its policy must accept the role named <project>-<environment>-walg-replication (output walg_replication_role_arn). null disables replication."
  type        = string
  default     = null

  validation {
    condition     = var.walg_replication_destination_bucket_arn == null || can(regex("^arn:aws[a-z-]*:s3:::[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.walg_replication_destination_bucket_arn))
    error_message = "walg_replication_destination_bucket_arn must be a bucket ARN like arn:aws:s3:::my-bucket."
  }
}
