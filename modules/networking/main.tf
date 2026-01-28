resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "infrawave"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "infrawave-public"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "infrawave-private"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"  # New CIDR block
  availability_zone = "us-east-1b"   # DIFFERENT AZ than private-subnet (us-east-1a)

  tags = {
    Name = "infrawave-private-2"
  }
}
