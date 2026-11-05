data "aws_route53_zone" "domain" {
  zone_id = var.route53_zone_id
}

resource "aws_route53_record" "apex" {
  count   = var.create_apex_record ? 1 : 0
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.domain
  type    = "A"
  ttl     = 300
  records = [aws_eip.main.public_ip]
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "*.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.main.public_ip]
}

moved {
  from = aws_route53_record.apex
  to   = aws_route53_record.apex[0]
}
