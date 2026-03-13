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


