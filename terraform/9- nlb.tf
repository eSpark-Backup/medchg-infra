# Network Load Balancer
resource "aws_lb" "k8s-nlb" {
  name               = "k8s-nlb"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.k8s-public.id
  }
  enable_deletion_protection = false
}

# Listener for NLB
resource "aws_lb_listener" "k8s-listner-http" {
  load_balancer_arn = aws_lb.k8s-nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-ingress-http.arn
  }
}
# Listener for NLB
resource "aws_lb_listener" "k8s-listner-https" {
  load_balancer_arn = aws_lb.k8s-nlb.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-ingress-https.arn
  }
}
# Listener for NLB
resource "aws_lb_listener" "k8s-listner-db5432" {
  load_balancer_arn = aws_lb.k8s-nlb.arn
  port              = 5432
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s-ingress-db30543.arn
  }
}