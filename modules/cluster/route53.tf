data "aws_route53_zone" "primary" {
  name         = format("%s.",var.r53zone)
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = format("%s.%s", var.environment, var.r53zone)
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

output "lb_data" {
    value = aws_route53_record.www.name
}
