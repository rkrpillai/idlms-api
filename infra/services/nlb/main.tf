resource "aws_lb_target_group" "multi" {
  for_each    = { for port in var.additional_ports : tostring(port) => port }
  name        = "${var.name}-tg-${each.key}"
  port        = each.value
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = each.value
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg-${each.key}"
  })
}


resource "aws_lb_target_group_attachment" "multi" {
  for_each = {
    for combo in flatten([
      for port in var.additional_ports : [
        for ip in var.target_ips : {
          key = "${port}-${ip}"
          port = port
          ip   = ip
        }
      ]
    ]) : combo.key => combo
  }

  target_group_arn = aws_lb_target_group.multi[each.value.port].arn
  target_id        = each.value.ip
  port             = each.value.port
}

resource "aws_lb_listener" "this" {
  for_each          = { for port in var.additional_ports : tostring(port) => port }
  load_balancer_arn = aws_lb.this.arn
  port              = each.value
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.multi[each.key].arn
  }
}

