resource "aws_vpc" "private_integrations_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.private_integrations_vpc.id
  cidr_block              = "10.0.0.0/18"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                    = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PublicSubnet1"
    "aws-tutorial:subnet-name" = "Public"
    "aws-tutorial:subnet-type" = "Public"
  }
}

resource "aws_route_table" "public_route_table_1" {
  vpc_id = aws_vpc.private_integrations_vpc.id

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PublicSubnet1"
  }
}

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table_1.id
}

resource "aws_eip" "public_subnet_1_eip" {
  vpc = true

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PublicSubnet1"
  }
}

resource "aws_nat_gateway" "public_subnet_1_nat_gateway" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.public_subnet_1_eip.id

  tags = {
    Name = "PrivateIntegrationsStack/PrivateIntegrationsTutorialVPC/PublicSubnet1"
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
  subnets            = [aws_subnet.public_subnet_1.id]

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

  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  task_role_arn      = "arn:aws:iam::123456789012:role/ecsTaskRole"
}

resource "aws_ecs_service" "springboot_service" {
  name            = "SpringBootService"
  cluster         = aws_ecs_cluster.private_integrations_cluster.id
  task_definition = aws_ecs_task_definition.springboot_task.arn

  desired_count          = 2
  launch_type            = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id]
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
