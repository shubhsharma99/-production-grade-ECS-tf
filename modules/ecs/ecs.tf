resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = "986129559431.dkr.ecr.us-east-1.amazonaws.com/my-ecs-app:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.app.arn

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.service_name
    container_port   = 80
  }

  depends_on = [aws_ecs_task_definition.app]
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] #
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//--------------------------------

# Create the ECS Auto Scaling Target first
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity        = 5
  min_capacity        = 1
  resource_id         = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension  = "ecs:service:DesiredCount"
  service_namespace   = "ecs"

  depends_on = [aws_ecs_service.service]  # Ensures ECS service is created before scaling target
}

# Scale Up Policy
resource "aws_appautoscaling_policy" "scale_up" {
  name                   = "scale-up"
  policy_type            = "TargetTrackingScaling"
  resource_id           = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension    = "ecs:service:DesiredCount"
  service_namespace     = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value         = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown     = 300
    scale_out_cooldown    = 300
  }

  depends_on = [aws_appautoscaling_target.ecs_target]  # Ensure the scaling target is created first
}

# Scale Down Policy
resource "aws_appautoscaling_policy" "scale_down" {
  name                   = "scale-down"
  policy_type            = "TargetTrackingScaling"
  resource_id           = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension    = "ecs:service:DesiredCount"
  service_namespace     = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value         = 20.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown     = 300
    scale_out_cooldown    = 300
  }

  depends_on = [aws_appautoscaling_target.ecs_target]  # Ensure the scaling target is created first
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "scale-up-cpu-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 50
  alarm_description         = "Scale up if CPU utilization > 50%"
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "scale-down-cpu-utilization"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 20
  alarm_description         = "Scale down if CPU utilization < 20%"
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}