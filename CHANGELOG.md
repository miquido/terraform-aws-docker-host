# 1.0.0 (2026-10-07)


* feat!: build on docker-host v2; CloudWatch logs/metrics, built-in registry, gzip user_data ([52bdaa4](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/52bdaa47056c145784ef43664420e3ece03c9dde))


### Bug Fixes

* Added .terraform.lock.hcl for validate to work ([c32a815](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/c32a815b190f9c4a218b432cbcfe31999b6f3dd0))
* pin the CloudWatch agent image ([72292dd](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/72292dd0c6b23f830621d8bdf06f3acb82626102))
* require registry_htpasswd when the built-in registry is enabled ([529862a](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/529862aa2ae332b863495f7fb656d59293e97d81))


### Features

* built-in registry with generated basic-auth credentials (enable_registry = true is enough) ([a8e6824](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/a8e6824bd0d928859a765393ca7905ced13bf98c))
* metrics + resotre script ([0164979](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/016497900e9c485379c6c88caf9b319ce7bc0b59))
* run prune on schedule ([583c852](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/583c852ad8405099b72e387c9a924d164aa9c7f5))
* walg ([f528a5a](https://gitlab.miquido.com/miquido/terraform/aws-docker-host/commit/f528a5a0d86171e16b60ab72041c85695e29228c))


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
