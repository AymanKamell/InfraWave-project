resource "aws_network_acl" "private-nacl"{
  vpc_id = aws_vpc.main.id

  # ────────────────────────────────────────────────
  # INGRESS RULES (traffic ENTERING private subnet)
  # ────────────────────────────────────────────────

  # 1. Allow SSH from admin IP (for backend EC2 management)
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = "10.0.0.0/24"  # 🔒 Replace with your actual IP!
  }

  # 2. Allow frontend → backend API requests (CRITICAL MISSING RULE!)
  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3000   # Backend service port
    to_port    = 3000
    cidr_block = "10.0.0.0/24"  # Public subnet CIDR (frontend)
  }

  # 3. Allow RDS → backend responses (RDS replies to backend's ephemeral ports)
  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024   # Backend's ephemeral ports
    to_port    = 65535
    cidr_block = "10.0.1.0/24"  # RDS subnet CIDR (adjust if RDS in separate subnet)
  }

  # 4. Allow ICMP for diagnostics (ping)
  ingress {
    rule_no    = 130
    action     = "allow"
    protocol   = "icmp"
    from_port  = 8   # Echo Request
    to_port    = -1
    cidr_block = "10.0.0.0/16"  # From anywhere in VPC
  }

  # ────────────────────────────────────────────────
  # EGRESS RULES (traffic LEAVING private subnet)
  # ────────────────────────────────────────────────

  # 1. Allow backend → RDS connections (CRITICAL MISSING RULE!)
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = "10.0.1.0/24"  # RDS subnet CIDR
  }

  # 2. Allow backend → frontend responses (backend replies to frontend's ephemeral ports)
  egress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024   # Frontend's ephemeral ports
    to_port    = 65535
    cidr_block = "10.0.0.0/24"  # Public subnet CIDR
  }

  # 3. Allow backend to fetch updates via NAT Gateway (internet access)
  egress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  # 4. Allow backend → internet responses (ephemeral ports for package downloads)
  egress {
    rule_no    = 140
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  # 5. Allow ICMP replies
  egress {
    rule_no    = 150
    action     = "allow"
    protocol   = "icmp"
    from_port  = 0   # Echo Reply
    to_port    = -1
    cidr_block = "0.0.0.0/0"
  }

  # ────────────────────────────────────────────────
  # DEFAULT DENY (explicit catch-all)
  # ────────────────────────────────────────────────
  ingress {
    rule_no    = 65535
    action     = "deny"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 65535
    action     = "deny"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "infrawave-private-nacl"
  }
}

# Explicit subnet association
resource "aws_network_acl_subnet_association" "private" {
  network_acl_id = aws_network_acl.private-nacl.id
  subnet_id      = aws_subnet.private-subnet.id
}