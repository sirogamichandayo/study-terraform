resource "aws_vpc" "sbcntr_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "sbcntrVpc"
  }
}

resource "aws_subnet" "sbcntr_subnet_private_container_1a" {
  cidr_block        = "10.0.8.0/24"
  vpc_id            = aws_vpc.sbcntr_vpc.id
  availability_zone = "ap-northeast-1a"

  map_public_ip_on_launch = false

  tags = {
    Name  = "sbcntr_subnet-private-container-1a"
    Value = "Isolated"
  }
}

resource "aws_subnet" "sbcntr_subnet_private_container_1c" {
  cidr_block        = "10.0.9.0/24"
  vpc_id            = aws_vpc.sbcntr_vpc.id
  availability_zone = "ap-northeast-1c"

  map_public_ip_on_launch = false

  tags = {
    Name  = "sbcntr-subnet-private-container-1c"
    Value = "Isolated"
  }
}

resource "aws_route_table" "sbcntr_route_table_app" {
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-route-app"
  }
}

resource "aws_route_table_association" "sbcntr_route_app_association_1a" {
  route_table_id = aws_route_table.sbcntr_route_table_app.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_container_1a.id
}

resource "aws_route_table_association" "sbcntr_route_app_association_1c" {
  route_table_id = aws_route_table.sbcntr_route_table_app.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_container_1a.id
}

resource "aws_subnet" "sbcntr_subnet_private_db_1a" {
  cidr_block              = "10.0.16.0/24"
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name : "sbcntr-subnet-private-db-1a"
    Type : "Isolated"
  }
}

resource "aws_subnet" "sbcntr_subnet_private_db_1c" {
  cidr_block              = "10.0.17.0/24"
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name : "sbcntr-subnet-private-db-1c"
    Type : "Isolated"
  }
}

resource "aws_route_table" "sbcntr_route_table_db" {
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Name = "sbcntr-route-db"
  }
}

resource "aws_route_table_association" "sbcntr_route_table_db_association_1a" {
  route_table_id = aws_route_table.sbcntr_route_table_db.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_db_1a.id
}

resource "aws_route_table_association" "sbcntr_route_table_db_association_1c" {
  route_table_id = aws_route_table.sbcntr_route_table_db.id
  subnet_id      = aws_subnet.sbcntr_subnet_private_db_1c.id
}

resource "aws_subnet" "sbcntr_subnet_public_ingress_1a" {
  cidr_block          = "10.0.0.0/24"
  vpc_id              = aws_vpc.sbcntr_vpc.id
  availability_zone   = "ap-northeast-1a"
  MapPublicIpOnLaunch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "sbcntr_subnet_public_ingress_1c" {
  cidr_block          = "10.0.1.0/24"
  vpc_id              = aws_vpc.sbcntr_vpc.id
  availability_zone   = "ap-northeast-1c"
  MapPublicIpOnLaunch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c"
    Type = "Public"
  }
}

resource "aws_route_table" "sbcntr_route_table_ingress" {
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Name = "sbcntr-route-ingress"
  }
}

resource "aws_route_table_association" "sbcntr_table_ingress_association_1a" {
  route_table_id = aws_route_table.sbcntr_route_table_ingress.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_ingress_1a.id
}

resource "aws_route_table_association" "sbcntr_table_ingress_association_1c" {
  route_table_id = aws_route_table.sbcntr_route_table_ingress.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_ingress_1c.id
}

resource "aws_route" "sbcntr_route_ingress_default" {
  route_table_id         = aws_route_table.sbcntr_route_table_ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sbcntr_internet_gateway.id
}

# 管理用サーバー周りの設定
resource "aws_subnet" "sbcntr_subnet_public_management_1a" {
  cidr_block              = "10.0.240.0/24"
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "sbcntr-subnet-public-management-1a"
    Type = "public"
  }
}

resource "aws_subnet" "sbcntr_subnet_public_management_1c" {
  cidr_block              = "10.0.241.0/24"
  vpc_id                  = aws_vpc.sbcntr_vpc.id
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "sbcntr-subnet-public-management-1c"
    Type = "public"
  }
}

resource "aws_route_table_association" "sbcntr_table_management_association_1a" {
  route_table_id = aws_route_table.sbcntr_route_table_app.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_management_1a.id
}

resource "aws_route_table_association" "sbcntr_table_management_association_1c" {
  route_table_id = aws_route_table.sbcntr_route_table_app.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_management_1c.id
}

# インターネットのgwの作成
resource "aws_internet_gateway" "sbcntr_internet_gateway" {
  vpc_id = aws_vpc.sbcntr_vpc.id
  tags = {
    Name = "sbcntr-igw"
  }
}
