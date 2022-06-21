resource "aws_security_group" "sbcntr_sg_ingress" {
  description = "Security group for ingress"
  name        = "ingress"
  vpc_id      = aws_vpc.sbcntr_vpc.id
  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "from 0.0.0.0/0:80"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    ipv6_cidr_blocks = ["::/0"]
    description      = "from ::/0:80"
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
  }
  tags = {
    Name = "sbcntr-sg-ingress"
  }
}

resource "aws_security_group" "sbcntr_sg_management" {
  description = "Security Group of management server"
  name        = "management"
  vpc_id      = aws_vpc.sbcntr_vpc.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "sbcntr-sg-management"
  }
}

resource "aws_security_group" "sbcntr_sg_backend_container" {
  description = "Security Group of management server"
  name        = "backend container"
  vpc_id      = aws_vpc.sbcntr_vpc.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "sbcntr-sg-backend-container"
  }
}

resource "aws_security_group" "sbcntr_sg_frontend_container" {
  description = "Security group of backend app"
  name        = "frontend container"
  vpc_id      = aws_vpc.sbcntr_vpc.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "sbcntr-sg-front-container"
  }
}

resource "aws_security_group" "sbcntr_sg_internal" {
  description = "Security group for internal load balancer"
  name        = "internal"
  vpc_id      = aws_vpc.sbcntr_vpc.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    Description = "Allow all outbound traffic by default"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "sbcntr-sg-internal"
  }
}

resource "aws_security_group" "sbcntr_sg_db" {
  description = "Security Group of database"
  name        = "database"
  vpc_id      = aws_vpc.sbcntr_vpc.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "sbcntr-sg-db"
  }
}

## Internet LB -> Front Container
resource "aws_security_group_rule" "sbcntr_sg_front_container_from_sg_ingress" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "HTTP for Ingress"
  from_port                = 80
  to_port                  = 80
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  source_security_group_id = aws_security_group.sbcntr_sg_frontend_container.id
}

## Front Container -> Internal LB
resource "aws_security_group_rule" "sbcntr_sg_internal_from_sg_front_container" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "HTTP for front container"
  from_port                = 80
  to_port                  = 80
  security_group_id        = aws_security_group.sbcntr_sg_frontend_container.id
  source_security_group_id = aws_security_group.sbcntr_sg_internal.id
}

## Internal LB -> Back Container
resource "aws_security_group_rule" "sbcntr_sg_backend_container_from_sg_internal" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "HTTP for internal lb"
  from_port                = 80
  to_port                  = 80
  security_group_id        = aws_security_group.sbcntr_sg_internal.id
  source_security_group_id = aws_security_group.sbcntr_sg_backend_container.id
}

## Back Container -> DB
resource "aws_security_group_rule" "sbcntr_sg_db_from_back_container_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "MySQL protocol from backend App"
  from_port                = 3306
  to_port                  = 3306
  security_group_id        = aws_security_group.sbcntr_sg_backend_container.id
  source_security_group_id = aws_security_group.sbcntr_sg_db.id
}

## Front Container -> DB
resource "aws_security_group_rule" "sbcntr_sg_db_from_front_container_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "MySQL protocol from frontend App"
  from_port                = 3306
  to_port                  = 3306
  security_group_id        = aws_security_group.sbcntr_sg_frontend_container.id
  source_security_group_id = aws_security_group.sbcntr_sg_db.id
}

## Management Server -> DB
resource "aws_security_group_rule" "sbcntr_sg_db_from_sg_management_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "MySQL protocol from management server"
  from_port                = 3306
  to_port                  = 3306
  security_group_id        = aws_security_group.sbcntr_sg_management.id
  source_security_group_id = aws_security_group.sbcntr_sg_db.id
}

## Management Server -> Internal LB
resource "aws_security_group_rule" "sbcntr_sg_internal_from_sg_management_tcp" {
  type                     = "ingress"
  protocol                 = "tcp"
  description              = "HTTP for management server"
  from_port                = 80
  to_port                  = 80
  security_group_id        = aws_security_group.sbcntr_sg_management.id
  source_security_group_id = aws_security_group.sbcntr_sg_internal.id
}




