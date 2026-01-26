resource "aws_route_table" "public-rt"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  

  tags = {
    Name = "infrawave-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}


# private routing table:-
resource "aws_route_table" "private-rt"{
  vpc_id = aws_vpc.main.id

  # ONLY define non-local route:
  route {
    cidr_block     = "0.0.0.0/0"          # Internet-bound traffic (for updates)
    nat_gateway_id = aws_nat_gateway.nat.id  # ← NOT gateway_id!
  }

  tags = {
    Name = "infrawave-private-rt"
  }
}

resource "aws_route_table_association" "private"{
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
