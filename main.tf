resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

// Auto launch config and scaling config group

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
#!/bin/bash
echo ECS_CLUSTER=${local.cluster_name} >> /etc/ecs/ecs.config
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config
EOT
  }
}

resource "aws_launch_configuration" "lc" {
  associate_public_ip_address = true

  name_prefix = null
  name        = "ecs-${local.cluster_name}-lc"

  key_name             = ${local.key_name}
  image_id             = "ami-0a5d07e2b337abadb"
  instance_type        = "t2.micro"
  iam_instance_profile = "arn:aws:iam::375605501954:instance-profile/ecsInstanceRole"
  ebs_optimized        = false

  security_groups = [
    ${local.security_groups}
  ]

  user_data = data.cloudinit_config.config.rendered

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      user_data
    ]
  }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix = null
  name        = "ecs-${local.cluster_name}-asg"

  availability_zones = [
    "ap-southeast-2b",
    "ap-southeast-2a",
    "ap-southeast-2c"
  ]

  launch_configuration = aws_launch_configuration.lc.name

  min_size         = 0
  max_size         = 1
  desired_capacity = 1

  health_check_grace_period = 0

  tag {
    key                 = "Description"
    propagate_at_launch = true
    value               = "This instance is the part of the Auto Scaling group which was created through ECS Console"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ECS Instance - EC2ContainerService-cluster"
  }
}

// ECS task definition

resource "aws_ecs_task_definition" "task" {
  family                   = "task"
  requires_compatibilities = ["EC2"]

  network_mode = "bridge"
  memory       = 128
  cpu          = 1024

  container_definitions = <<DEFINITION
    [
      {
        "name": "container-web",
        "image": "public.ecr.aws/lts/nginx:latest",
        "essential": true,
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ],
        "memory": 128,
        "cpu": 1024
      }
    ]
    DEFINITION

  tags = {}
}

// ECS service

resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "EC2"
  desired_count   = 1

  tags = {}
}
