resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "todoapp-vpc"
  }

}

#public subnet 

resource "aws_subnet" "public_1" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ca-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "todoapp-public-subnet-1-ca-west-1a"
  }

}

resource "aws_subnet" "public_2" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ca-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "todoapp-public-subnet-2-ca-west-1b"
  }

}

#private Subnet
resource "aws_subnet" "private_1" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ca-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "todoapp-private-subnet-1-ca-west-1a"
  }

}

resource "aws_subnet" "private_2" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ca-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "todoApp-private-subnet-2-ca-west-1b"
  }

}

#Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "todoapp-igw"
  }

}

#Elastic IP for NAT gw

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = "todoapp-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}




#NAT gw's (one per AZ  in ca-west-1a)

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "todoapp-nat-ca-west-1a"
  }

  depends_on = [aws_internet_gateway.main]
}

# public Route Table

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "todoapp-public-rt"
  }

}

#Link public rt's with Public subnets 

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

#Private rt shared by both private subnets

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "todoapp-private-rt"
  }

}

# ECS tasks are in private subnets but need internet access to pull Docker images!
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

#link private rt with both private subnets

resource "aws_route_table_association" "private_1" {

  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "private_2" {

  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id

}

#Security Groups

resource "aws_security_group" "alb" {

  name        = "todoapp-alb-sg"
  description = "Security group for alb"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80 #http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Http is allowed from internet"
  }

  ingress {
    from_port   = 443 #https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Https is allowed from internet"
  }

  egress {
    description = "Allow traffic to targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Alb can talk to EC2,ECS, k8s etc
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todoapp-alb-sg"
  }

}

#ECS security Group => only from ALB

resource "aws_security_group" "ecs" {
  name        = "todoapp-ecs-sg"
  description = "Sg for ECS containers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8008
    to_port         = 8008
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Traffic from ALB on port 8080 allowed"
  }

  #ingress 8008 from ALB SG and 80 for ECS
  ingress {
    description     = "Traffic from ALB on port 80 for frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound allowed"
  }

  tags = {
    Name = "todoapp-ecs-sg"
  }


}

# RDS Security group allow traffic from ECS only
resource "aws_security_group" "rds" {
  name        = "todoapp-rds-sg"
  description = "Security group for RDS MySQL database"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL from ecs 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description     = "Allow MySQL from ECS containers"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "todoapp-rds-sg"
  }
}

# outputs

# vpc 
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# Subnet 
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

# Gateway 
output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

# Sg
output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS Security Group ID"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}



# RDS DATABASE 

# DB Subnet Group 
resource "aws_db_subnet_group" "main" {
  name       = "todoapp-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "todoapp-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier     = "todoapp-db"
  engine         = "mysql"
  engine_version = "8.0"


  instance_class = "db.t3.micro"


  allocated_storage     = 20 # GB
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database
  db_name  = "todoapp"
  username = "todouser"
  password = "TodoApp2026SecurePassword!" # will use secret manager
  port     = 3306

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false # Keep private!

  # Backups
  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # High Availability
  multi_az = false # Will be true for production

  # Deletion protection
  deletion_protection       = false # will be set to true for production
  skip_final_snapshot       = true  # ill be set false for production
  final_snapshot_identifier = "todoapp-db-final-snapshot"

  # Performance
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name = "todoapp-db"
  }
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_database_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}


#  ECR REPOSITORIES 

# Backend ECR Repository
resource "aws_ecr_repository" "backend" {
  name                 = "todoapp-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Scan for vulnerabilities
  }

  tags = {
    Name = "todoapp-backend"
  }
}

# Frontend ECR Repository
resource "aws_ecr_repository" "frontend" {
  name                 = "todoapp-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "todoapp-frontend"
  }
}

# ECR Outputs
output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}


# ECS CLUSTER 

resource "aws_ecs_cluster" "main" {
  name = "todoapp-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "todoapp-cluster"
  }
}

#  ECS TASK EXECUTION ROLE

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "todoapp-ecs-task-execution-role"

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
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#  BACKEND TASK DEFINITION

resource "aws_ecs_task_definition" "backend" {
  family                   = "todoapp-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8008
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "DB_HOST"
          value = split(":", aws_db_instance.main.endpoint)[0]
        },
        {
          name  = "DB_PORT"
          value = "3306"
        },
        {
          name  = "DB_USERNAME"
          value = "todouser"
        },
        {
          name  = "DB_PASSWORD"
          value = "TodoApp2026SecurePassword!"
        },
        {
          name  = "DB_DATABASE"
          value = "todoapp"
        },
        {
          name  = "JWT_SECRET"
          value = "your-jwt-secret-key-change-in-production"
        },
        {
          name  = "JWT_EXPIRES_IN"
          value = "7d"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/todoapp-backend"
          "awslogs-region"        = "ca-west-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

# FRONTEND TASK DEFINITION 

resource "aws_ecs_task_definition" "frontend" {
  family                   = "todoapp-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/todoapp-frontend"
          "awslogs-region"        = "ca-west-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

# APPLICATION LOAD BALANCER 

resource "aws_lb" "main" {
  name               = "todoapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "todoapp-alb"
  }
}

# TARGET GROUPS 

resource "aws_lb_target_group" "backend" {
  name        = "todoapp-backend-tg"
  port        = 8008
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200,404"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "todoapp-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
}

# ALB LISTENER 

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

#  LISTENER RULES 

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# ECS SERVICES 

resource "aws_ecs_service" "backend" {
  name            = "todoapp-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8008
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "frontend" {
  name            = "todoapp-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

# OUTPUTS 

output "alb_dns_name" {
  description = "ALB DNS name - used this to access app!"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Full ALB URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

#  Additional IAM Policy for cloudwatch logs

resource "aws_iam_role_policy" "ecs_task_execution_cloudwatch" {
  name = "todoapp-ecs-task-execution-cloudwatch-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
