resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ECS Task Execution Role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ECS Task Role"
  }
}

resource "aws_vpc" "private_integrations_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.private_integrations_vpc.id
  cidr_block              = "10.0.128.0/18"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name                    = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet1"
    "aws-tutorial:subnet-name" = "Private"
    "aws-tutorial:subnet-type" = "Private"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.private_integrations_vpc.id
  cidr_block              = "10.0.192.0/18"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name                    = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet2"
    "aws-tutorial:subnet-name" = "Private"
    "aws-tutorial:subnet-type" = "Private"
  }
}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.private_integrations_vpc.id

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet1"
  }
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.private_integrations_vpc.id

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet2"
  }
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

resource "aws_nat_gateway" "private_subnet_1_nat_gateway" {
  subnet_id     = aws_subnet.private_subnet_1.id
  allocation_id = aws_eip.private_subnet_1_eip.id

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet1"
  }
}

resource "aws_nat_gateway" "private_subnet_2_nat_gateway" {
  subnet_id     = aws_subnet.private_subnet_2.id
  allocation_id = aws_eip.private_subnet_2_eip.id

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet2"
  }
}

resource "aws_security_group" "elb_security_group" {
  vpc_id = aws_vpc.private_integrations_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 33333
    to_port     = 33333
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PrivateIntegrationsStackPrivateIntegrationsTutorialServiceLBCB8E0368"
  }
}

resource "aws_lb" "private_integrations_lb" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_security_group.id]
  subnets            = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "PrivateIntegrationsTutorialServiceLB"
  }
}

resource "aws_lb_target_group" "springboot_target_group" {
  name        = "SpringBootTargetGroup"
  port        = 33333
  protocol    = "HTTP"
  vpc_id      = aws_vpc.private_integrations_vpc.id
  target_type = "ip"

  health_check {
    path                = "/listallcustomers"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "SpringBootTargetGroup"
  }
}

resource "aws_lb_listener" "springboot_listener" {
  load_balancer_arn = aws_lb.private_integrations_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot_target_group.arn
  }
}

resource "aws_ecs_task_definition" "springboot_task" {
  family                   = "SpringBootApp"
  cpu                      = "512"
  memory                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name        = "SpringBootApp"
      image       = "tushardashpute/springboot-k8s:latest"
      cpu         = 512
      memory      = 2048
      essential   = true
      portMappings = [{ containerPort = 33333, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/springboot"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "springboot_service" {
  name            = "SpringBootService"
  cluster         = aws_ecs_cluster.private_integrations_cluster.id
  task_definition = aws_ecs_task_definition.springboot_task.arn

  desired_count          = 2
  launch_type            = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.elb_security_group.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.springboot_target_group.arn
    container_name   = "SpringBootApp"
    container_port   = 33333
  }

  depends_on = [aws_lb_listener.springboot_listener]
}

resource "aws_eip" "private_subnet_1_eip" {
  vpc = true

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet1"
  }
}

resource "aws_eip" "private_subnet_2_eip" {
  vpc = true

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PrivateSubnet2"
  }
}
