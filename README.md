# aws-docker-host <a href="https://miquido.com"><img align="right" src="https://cdn.miquido.dev/miquido-logo.png" width="150" /></a>

AWS EC2 Docker host with Traefik, OIDC runner, and WAL-G backups

## Development

```bash
make init   # run once after cloning
make readme # regenerate README.md
make lint   # lint terraform code
```

## Usage

```hcl
module "docker_host" {
  source = "git@gitlab.miquido.com:miquido/terraform/aws-docker-host.git?ref=v1.0.0"

  project     = "myproject"
  environment = "dev"
  region      = "eu-central-1"

  ami_id          = "ami-0a1b2c3d4e5f67890"
  instance_type   = "t3.small"
  subnet_id       = "subnet-0a1b2c3d4e5f67890"
  ssh_ip_range    = "10.0.0.0/8"
  domain          = "dev.example.com"
  acme_email      = "ops@example.com"
  route53_zone_id = "Z1234567890ABC"

  oidc_jwks_url      = "https://gitlab.com/-/jwks"
  oidc_audience      = "https://gitlab.com"
  oidc_expected_subs = ["project_path:mygroup/myrepo:ref_type:branch:ref:main"]
  ip_allowlist       = "0.0.0.0/0"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.51.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_docker_host"></a> [docker\_host](#module\_docker\_host) | git::https://github.com/miquido/terraform-docker-host.git | v2.1.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_dashboard.traefik](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_group.docker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ebs_volume.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.route53_acme](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.walg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route53_record.apex](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.wildcard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.walg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.walg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.walg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.walg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [random_password.registry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acme_email"></a> [acme\_email](#input\_acme\_email) | Email for Let's Encrypt ACME registration | `string` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Ubuntu 22.04 LTS AMI ID (region-specific) | `string` | n/a | yes |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days to retain CloudWatch logs. | `number` | `30` | no |
| <a name="input_data_volume_size"></a> [data\_volume\_size](#input\_data\_volume\_size) | n/a | `number` | `20` | no |
| <a name="input_docker_compose_runner_image"></a> [docker\_compose\_runner\_image](#input\_docker\_compose\_runner\_image) | n/a | `string` | `"ghcr.io/miquido/gitlab-docker-compose-host:v1.4.0"` | no |
| <a name="input_docker_prune_schedule"></a> [docker\_prune\_schedule](#input\_docker\_prune\_schedule) | Cron schedule for Docker image pruning via Ofelia. Set to empty string to disable. | `string` | `"0 3 * * *"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Base domain (e.g. dmc.example.com). Wildcard cert will be issued for *.domain. | `string` | n/a | yes |
| <a name="input_ecr_registry_url"></a> [ecr\_registry\_url](#input\_ecr\_registry\_url) | ECR registry URL (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com). Leave empty to skip ECR setup. | `string` | `""` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Ship Docker logs to CloudWatch Logs (awslogs driver) and Traefik metrics through the CloudWatch Agent. | `bool` | `true` | no |
| <a name="input_enable_registry"></a> [enable\_registry](#input\_enable\_registry) | Run a docker registry on the host (registry.<domain>) instead of ECR, protected with basic auth. Credentials are generated unless registry\_username/registry\_password/registry\_htpasswd are given; read them from the registry\_* outputs. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t3.small"` | no |
| <a name="input_ip_allowlist"></a> [ip\_allowlist](#input\_ip\_allowlist) | CIDR range allowed to access the docker-compose-runner endpoint | `string` | n/a | yes |
| <a name="input_oidc_audience"></a> [oidc\_audience](#input\_oidc\_audience) | Expected OIDC audience for docker-compose-runner | `string` | n/a | yes |
| <a name="input_oidc_expected_subs"></a> [oidc\_expected\_subs](#input\_oidc\_expected\_subs) | List of expected OIDC subjects for docker-compose-runner | `list(string)` | n/a | yes |
| <a name="input_oidc_jwks_url"></a> [oidc\_jwks\_url](#input\_oidc\_jwks\_url) | JWKS URL for docker-compose-runner OIDC authentication | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_registry_htpasswd"></a> [registry\_htpasswd](#input\_registry\_htpasswd) | Override: htpasswd entries (bcrypt, comma-separated) for the built-in registry. Default: one entry for registry\_username with a generated password. | `string` | `""` | no |
| <a name="input_registry_password"></a> [registry\_password](#input\_registry\_password) | Override: password for registry\_username. Default: generated (see the registry\_password output). | `string` | `""` | no |
| <a name="input_registry_username"></a> [registry\_username](#input\_registry\_username) | Override: user of the built-in registry (and the one the host logs in with). Default: ci. | `string` | `""` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | n/a | `number` | `20` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route53 hosted zone ID for the domain | `string` | n/a | yes |
| <a name="input_ssh_ip_range"></a> [ssh\_ip\_range](#input\_ssh\_ip\_range) | CIDR allowed SSH access | `string` | n/a | yes |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | List of SSH public keys added to the ubuntu user's authorized\_keys on the EC2 instance. | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | n/a | yes |
| <a name="input_use_spot"></a> [use\_spot](#input\_use\_spot) | Use EC2 Spot instance (persistent, stop on interruption). Reduces cost ~70% for dev environments. | `bool` | `false` | no |
| <a name="input_walg_backup_retention_days"></a> [walg\_backup\_retention\_days](#input\_walg\_backup\_retention\_days) | Number of days to retain WAL-G backups in S3 before automatic deletion. | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_domain"></a> [domain](#output\_domain) | Base domain |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Elastic IP address of the instance |
| <a name="output_registry_password"></a> [registry\_password](#output\_registry\_password) | Password of the built-in registry (generated unless registry\_password was given) |
| <a name="output_registry_url"></a> [registry\_url](#output\_registry\_url) | Hostname of the built-in registry (empty when enable\_registry is false) |
| <a name="output_registry_username"></a> [registry\_username](#output\_registry\_username) | User of the built-in registry |
| <a name="output_walg_backup_bucket"></a> [walg\_backup\_bucket](#output\_walg\_backup\_bucket) | S3 bucket name for WAL-G backups |
<!-- END_TF_DOCS -->

## License

[MIT](LICENSE)
