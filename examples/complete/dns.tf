# The Route53 zone of the domain. The module only creates the A records (apex and wildcard) and the IAM policy for
# the DNS-01 challenge in a zone that already exists, so the example creates one.
resource "aws_route53_zone" "main" {
  name = var.domain
}
