# 1. Create the NACL (NO subnet_id here!)
#resource "aws_network_acl" "public-nacl"{
# vpc_id = aws_vpc.main.id
resource "aws_network_acl" "public-nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public-subnet.id] # ← KEY FIX: Associate here


  # INGRESS RULES (traffic ENTERING subnet)
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0" # HTTP from internet
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0" # HTTPS from internet
  }

  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = var.admin_ip # 🔒 SSH ONLY from your IP!
  }

  ingress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "10.0.0.0/16" # Responses from backend (VPC CIDR)
  }

  ingress {
    rule_no    = 140
    action     = "allow"
    protocol   = "icmp"
    from_port  = 8 # Echo Request (ping)
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  # EGRESS RULES (traffic LEAVING subnet)
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0" # Server can fetch HTTP resources
  }

  egress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0" # Server can fetch HTTPS resources
  }

  egress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0" # 🔑 CRITICAL: Responses to clients' ephemeral ports
  }

  egress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "10.0.0.0/16" # Communication to backend in private subnet
  }

  egress {
    rule_no    = 140
    action     = "allow"
    protocol   = "icmp"
    from_port  = 0 # Echo Reply
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  # Default deny rules (optional but explicit)
  ingress {
    rule_no    = 32766
    action     = "deny"
    protocol   = "-1" # All protocols
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 32766
    action     = "deny"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "infrawave-public-nacl"
  }
}


# 2. Explicitly associate NACL with subnet
#resource "aws_network_acl_subnet_association" "public" {
# network_acl_id = aws_network_acl.public-nacl.id
# subnet_id      = aws_subnet.public-subnet.id
#}
