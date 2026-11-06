# [2.5.0](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v2.4.0...v2.5.0) (2026-11-06)


### Features

* swap file on first boot (swap_size_gb, swappiness) ([b868292](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/b868292ce41b2519db8b13a4c1605cbf07837bb5))

# [2.4.0](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v2.3.0...v2.4.0) (2026-11-06)


### Features

* autoheal (terraform-docker-host v2.2.0), enable_autoheal default true ([cdc882e](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/cdc882e5f2fd3d6f83417d9d90fb58ac99db7892))

# [2.3.0](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v2.2.0...v2.3.0) (2026-11-05)


### Features

* version the WAL-G bucket ([36e36e4](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/36e36e47ad76c54e648d52d297548820ce3cfceb))

# [2.2.0](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v2.1.0...v2.2.0) (2026-11-05)


### Bug Fixes

* default docker-compose-runner image v1.4.2 ([4dba575](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/4dba57562062359809a8ff9cc6fc6994a74e994d))


### Features

* daily EBS snapshots of the data volume and restore from a snapshot ([5b935fa](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/5b935fa34a4d198fc46d47983d3e0c96d816d6f0))
* optional apex record and configurable Postgres ingress ([2f33ff8](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/2f33ff87a4addff7526353fcf0c1292c20b92366))

# [2.1.0](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v2.0.1...v2.1.0) (2026-10-12)


### Features

* docker-host 2.1.0 (pitr-marker for Postgres and MySQL on the host) ([9391e09](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/9391e09d8d9809b172fd246e9dd85031d6048113))

## [2.0.1](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v2.0.0...v2.0.1) (2026-10-07)


### Bug Fixes

* use docker-host v2.0.1 (fresh boots no longer abort in write_files) ([de80975](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/de809755dafd8eb69dcc37593de3ccbcb4553fa2))

# [2.0.0](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/compare/v1.3.1...v2.0.0) (2026-10-07)


* feat!: build on docker-host v2; CloudWatch logs/metrics, built-in registry, gzip user_data ([52bdaa4](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/52bdaa47056c145784ef43664420e3ece03c9dde))


### Bug Fixes

* Added .terraform.lock.hcl for validate to work ([c32a815](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/c32a815b190f9c4a218b432cbcfe31999b6f3dd0))
* pin the CloudWatch agent image ([72292dd](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/72292dd0c6b23f830621d8bdf06f3acb82626102))
* require registry_htpasswd when the built-in registry is enabled ([529862a](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/529862aa2ae332b863495f7fb656d59293e97d81))


### Features

* built-in registry with generated basic-auth credentials (enable_registry = true is enough) ([a8e6824](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/a8e6824bd0d928859a765393ca7905ced13bf98c))


### BREAKING CHANGES

* instances are created with user `ubuntu`; existing hosts keep their cloud-init
(user_data is ignored) until they are recreated.

Note: terraform_validate cannot pass until docker-host v2.0.0 is tagged (release the core first).

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>

# 1.0.0 (2026-06-23)


### Bug Fixes

* Added .terraform.lock.hcl for validate to work ([c32a815](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/c32a815b190f9c4a218b432cbcfe31999b6f3dd0))


### Features

* metrics + resotre script ([0164979](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/016497900e9c485379c6c88caf9b319ce7bc0b59))
* run prune on schedule ([583c852](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/583c852ad8405099b72e387c9a924d164aa9c7f5))
* walg ([f528a5a](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/f528a5a0d86171e16b60ab72041c85695e29228c))
