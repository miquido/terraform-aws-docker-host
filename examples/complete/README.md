# Example: a Docker host on AWS

Everything needed to run `terraform-aws-docker-host` from scratch: a minimal network (one public subnet), a
Route53 zone for the domain, and the module itself. Fill in `variables.auto.tfvars` and apply.

```bash
cp variables.auto.tfvars.example variables.auto.tfvars   # edit: domain, acme_email, allowed_cidr, OIDC settings
terraform init
terraform apply
```

The apply prints `nameservers`: **delegate the domain to them** (NS records in its parent zone). Until the
delegation is in place Traefik cannot issue the wildcard certificate (DNS-01) and the host is reachable only with a
default certificate.

Credentials of the built-in registry (`enable_registry`, default `true`) are generated:

```bash
terraform output registry_url
terraform output registry_username
terraform output -raw registry_password
```

## Checking a fresh host

There is no SSH requirement: the instance role allows SSM.

```bash
aws ssm start-session --target <instance-id>       # instance id: EC2 console, tag Project=<project>
cloud-init status --long                           # expect "status: done", no errors
docker ps                                          # traefik, runner, registry, ofelia, cloudwatch-agent
curl -s -o /dev/null -w '%{http_code}\n' https://registry.<domain>/v2/    # 401 without credentials
```

Deployments reach the host through `https://docker.<domain>/run-compose` with an OIDC token from the issuer
configured in `oidc_*`; the CI side is described in the `docker-host` core README. On the host,
`pitr-restore <compose project> "<time>"` restores a Postgres database from its WAL-G backup.

## Notes

- Costs: a `t3.small`, a 20 GB root and a 20 GB data volume, an Elastic IP. `terraform destroy` removes
  everything; empty the WAL-G bucket first (`walg_backup_bucket` output), it is not force-destroyed.
- The network here is the minimum for the example. In real setups pass your own `subnet_id` and zone.
- State is local. Configure a backend before keeping this environment.
