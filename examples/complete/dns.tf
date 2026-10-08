# The Route53 zone of the domain. The module only creates the A records (apex and wildcard) and the IAM policy for
# the DNS-01 challenge in a zone that already exists, so the example provides one: it creates the zone, or uses
# an existing, already delegated one when route53_zone_id is set.
resource "aws_route53_zone" "main" {
  count = var.route53_zone_id == null ? 1 : 0
  name  = var.domain
}

locals {
  zone_id = var.route53_zone_id != null ? var.route53_zone_id : aws_route53_zone.main[0].zone_id
}
