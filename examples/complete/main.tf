data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

module "docker_host" {
  # Outside this repository use the released module:
  #   source = "git::https://github.com/miquido/terraform-aws-docker-host.git?ref=v2.0.1"
  source = "../.."

  project     = var.project
  environment = var.environment
  region      = var.region

  ami_id        = data.aws_ssm_parameter.ubuntu.value
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id

  domain          = var.domain
  acme_email      = var.acme_email
  route53_zone_id = aws_route53_zone.main.zone_id

  ssh_ip_range       = var.allowed_cidr
  ip_allowlist       = var.allowed_cidr
  ssh_public_keys    = var.ssh_public_keys
  oidc_jwks_url      = var.oidc_jwks_url
  oidc_audience      = var.oidc_audience
  oidc_expected_subs = var.oidc_expected_subs

  # Registry on the host (basic auth, credentials generated and exposed as outputs) or ECR, not both.
  enable_registry = var.enable_registry

  enable_metrics = true # Docker logs and Traefik metrics to CloudWatch
}
