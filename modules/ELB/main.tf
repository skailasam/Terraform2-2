resource "aws_elb" "this" {
  count = var.create_elb ? 1 : 0

  name        = var.name
  name_prefix = var.name_prefix

  subnets         = var.subnets
  internal        = var.internal
  security_groups = var.security_groups

  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  dynamic "listener" {
    for_each = var.listener
    content {
      instance_port      = listener.value.instance_port
      instance_protocol  = listener.value.instance_protocol
      lb_port            = listener.value.lb_port
      lb_protocol        = listener.value.lb_protocol
    }
  }

  dynamic "access_logs" {
    for_each = length(keys(var.access_logs)) == 0 ? [] : [var.access_logs]
    content {
      bucket        = access_logs.value.bucket
      bucket_prefix = lookup(access_logs.value, "bucket_prefix", null)
      interval      = lookup(access_logs.value, "interval", null)
      enabled       = lookup(access_logs.value, "enabled", true)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}