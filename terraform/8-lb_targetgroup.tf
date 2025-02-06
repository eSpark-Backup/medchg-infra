resource "aws_lb_target_group" "k8s-ingress-http" {
  name        = "k8s-ingress-http"
  target_type = "instance"
  port        = 32080
  protocol    = "TCP"
  vpc_id      = aws_vpc.k8s-vpc.id

  #outlines path, protocol, and port of healthcheck
  health_check {
    protocol = "TCP"
  }
}
resource "aws_lb_target_group" "k8s-ingress-https" {
  name        = "k8s-ingress-https"
  target_type = "instance"
  port        = 32443
  protocol    = "TCP"
  vpc_id      = aws_vpc.k8s-vpc.id

  #outlines path, protocol, and port of healthcheck
  health_check {
    protocol = "TCP"
  }
}
resource "aws_lb_target_group" "k8s-ingress-db30543" {
  name        = "k8s-ingress-db30543"
  target_type = "instance"
  port        = 30543
  protocol    = "TCP"
  vpc_id      = aws_vpc.k8s-vpc.id

  #outlines path, protocol, and port of healthcheck
  health_check {
    protocol = "TCP"
  }
}
resource "aws_lb_target_group" "k8s-ingress-db30544" {
  name        = "k8s-ingress-db30544"
  target_type = "instance"
  port        = 30544
  protocol    = "TCP"
  vpc_id      = aws_vpc.k8s-vpc.id

  #outlines path, protocol, and port of healthcheck
  health_check {
    protocol = "TCP"
  }
}

#attach target group to instances
resource "aws_lb_target_group_attachment" "k8s-ingress-http-attach" {
  count = length(aws_instance.k8s_workers)
  target_group_arn = aws_lb_target_group.k8s-ingress-http.arn
  target_id        = aws_instance.k8s_workers[count.index].id
  port             = 32080
}
resource "aws_lb_target_group_attachment" "k8s-ingress-https-attach" {
  count = length(aws_instance.k8s_workers)
  target_group_arn = aws_lb_target_group.k8s-ingress-https.arn
  target_id        = aws_instance.k8s_workers[count.index].id
  port             = 32443
}
resource "aws_lb_target_group_attachment" "k8s-ingress-db30543-attach" {
  count = length(aws_instance.k8s_workers)
  target_group_arn = aws_lb_target_group.k8s-ingress-db30543.arn
  target_id        = aws_instance.k8s_workers[count.index].id
  port             = 30543
}
resource "aws_lb_target_group_attachment" "k8s-ingress-db30544-attach" {
  count = length(aws_instance.k8s_workers)
  target_group_arn = aws_lb_target_group.k8s-ingress-db30544.arn
  target_id        = aws_instance.k8s_workers[count.index].id
  port             = 30544
}