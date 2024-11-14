# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

# vpc 설정
resource "aws_vpc" "rookies-final" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "rookies-final-eks-node",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

# 퍼블릭 서브넷 정의 (CodeBuild 등 외부 접근 허용)
resource "aws_subnet" "public_subnet" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.rookies-final.id

  tags = tomap({
    "Name"                                      = "rookies-final-eks-public",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

# 프라이빗 서브넷 정의 (CodeBuild 및 내부 통신 전용)
resource "aws_subnet" "private_subnet" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index + 2}.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.rookies-final.id

  tags = tomap({
    "Name"                                      = "rookies-final-eks-private",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

# resource "aws_subnet" "rookies-final" {
#   count = 2

#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   cidr_block              = "10.0.${count.index}.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = aws_vpc.rookies-final.id

#   tags = tomap({
#     "Name"                                      = "rookies-final-eks-node",
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared",
#   })
# }


# 인터넷 게이트웨이 생성 (퍼블릭 서브넷과 연결)
resource "aws_internet_gateway" "rookies-final" {
  vpc_id = aws_vpc.rookies-final.id

  tags = {
    Name = "rookies-final-eks"
  }
}

# NAT 게이트웨이 설정 (프라이빗 서브넷의 외부 연결 허용)
resource "aws_eip" "nat_eip" {
  #vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id # 퍼블릭 서브넷 중 하나에 NAT 배치
}


# resource "aws_route_table" "rookies-final" {
#   vpc_id = aws_vpc.rookies-final.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.rookies-final.id
#   }
# }

# resource "aws_route_table_association" "rookies-final" {
#   count = 2

#   subnet_id      = aws_subnet.rookies-final.*.id[count.index]
#   route_table_id = aws_route_table.rookies-final.id
# }


# 퍼블릭 라우트 테이블 설정
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.rookies-final.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rookies-final.id
  }
}

# 퍼블릭 서브넷에 라우트 테이블 연결
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# 프라이빗 라우트 테이블 설정 (NAT 게이트웨이 연결)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.rookies-final.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# 프라이빗 서브넷에 라우트 테이블 연결
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
# # 보안 그룹 생성 (로드 밸런서 용)
# resource "aws_security_group" "alb_sg" {
#   name   = "rookies-final-alb-sg"
#   vpc_id = aws_vpc.rookies-final.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 가능
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # 모든 트래픽 허용
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "rookies-final-alb-sg"
#   }
# }

# # Application Load Balancer 생성
# resource "aws_lb" "example" {
#   name               = "rookies-final-alb"
#   internal           = false # 외부에서 접근할 수 있도록 설정
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = aws_subnet.public_subnet[*].id # 퍼블릭 서브넷 사용

#   enable_deletion_protection = false

#   tags = {
#     Name = "rookies-final-alb"
#   }
# }

# # 로드 밸런서 리스너 생성 (HTTP 포트 80)
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.example.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "forward"

#     target_group_arn = aws_lb_target_group.example.arn
#   }
# }

# # 로드 밸런서 타겟 그룹 생성
# resource "aws_lb_target_group" "example" {
#   name     = "rookies-final-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.rookies-final.id

#   health_check {
#     path                = "/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }
