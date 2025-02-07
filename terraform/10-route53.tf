# Route 53 A Record
resource "aws_route53_record" "medchgdotcom" {
  zone_id = "Z052580425Z8NYFH0JUZW"
  name    = "dfwcriticalcare.medchg.com" # Replace with your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.k8s-nlb.dns_name
    zone_id                = aws_lb.k8s-nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "stg-k8dotmedchgdotcom" {
  zone_id = "Z052580425Z8NYFH0JUZW"
  name    = "stg-k8.medchg.com" # Replace with your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.k8s-nlb.dns_name
    zone_id                = aws_lb.k8s-nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dev-k8dotmedchgdotcom" {
  zone_id = "Z052580425Z8NYFH0JUZW"
  name    = "dev-k8.medchg.com" # Replace with your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.k8s-nlb.dns_name
    zone_id                = aws_lb.k8s-nlb.zone_id
    evaluate_target_health = true
  }
}

# Route 53 A Record
resource "aws_route53_record" "k8s-pgadmin" {
  zone_id = "Z052580425Z8NYFH0JUZW"
  name    = "pgadmin.medchg.com" # Replace with your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.k8s-nlb.dns_name
    zone_id                = aws_lb.k8s-nlb.zone_id
    evaluate_target_health = true
  }
}

# Route 53 A Record
resource "aws_route53_record" "k8s-gitopsdotmedchgdotcom" {
  zone_id = "Z052580425Z8NYFH0JUZW"
  name    = "gitops.medchg.com" # Replace with your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.k8s-nlb.dns_name
    zone_id                = aws_lb.k8s-nlb.zone_id
    evaluate_target_health = true
  }
}