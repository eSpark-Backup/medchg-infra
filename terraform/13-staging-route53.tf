# Route 53 A Record
resource "aws_route53_record" "k8s-stg" {
  zone_id = "Z052580425Z8NYFH0JUZW"
  name    = "stg.medchg.com" # Replace with your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.k8s-nlb.dns_name
    zone_id                = aws_lb.k8s-nlb.zone_id
    evaluate_target_health = true
  }
}