variable "aws_profile" {
  description = "AWS CLI profile to use. null = default credential chain."
  type        = string
  default     = null
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "project" {
  description = "Used in names and tags."
  type        = string
  default     = "docker-host-example"
}

variable "environment" {
  type    = string
  default = "test"
}

variable "domain" {
  description = "Base domain of the host, e.g. dmc.example.com. A Route53 zone is created for it; delegate it (NS records, see the nameservers output) from its parent zone, otherwise the wildcard certificate cannot be issued."
  type        = string
}

variable "acme_email" {
  description = "Email for Let's Encrypt registration."
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR allowed to SSH to the host and to call the docker-compose-runner endpoint, e.g. your office range (203.0.113.0/24)."
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_public_keys" {
  description = "Optional: SSH keys for the ubuntu user. The instance role allows SSM, so a shell is also available without SSH (aws ssm start-session)."
  type        = list(string)
  default     = []
}

variable "oidc_jwks_url" {
  description = "JWKS URL of the OIDC issuer that authenticates deployments, e.g. https://gitlab.example.com/oauth/discovery/keys"
  type        = string
}

variable "oidc_audience" {
  description = "Expected audience of the OIDC token, e.g. https://gitlab.example.com"
  type        = string
}

variable "oidc_expected_subs" {
  description = "Allowed OIDC subjects (patterns), e.g. [\"project_path:my-group/**\"]"
  type        = list(string)
}

variable "enable_registry" {
  description = "Run a docker registry on the host (registry.<domain>) with generated basic-auth credentials instead of using ECR."
  type        = bool
  default     = true
}
