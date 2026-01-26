# ────────────────────────────────────────────────────────────────
# 1. FRONTEND EC2 SECURITY GROUP (Public Subnet - Web Server)
# ────────────────────────────────────────────────────────────────
resource "aws_security_group" "frontend" {
  name        = "infrawave-frontend-sg"
  description = "Allow HTTP/HTTPS from internet + SSH from admin IP"
  vpc_id      = aws_vpc.main.id

  # Ingress: Web traffic from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: Admin SSH access (LOCKED DOWN)
  ingress {
    description = "SSH from administrator IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]  # 🔒 CRITICAL: NOT 0.0.0.0/0!
  }

  # Egress: Allow outbound to backend + internet (stateful = responses auto-allowed)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infrawave-frontend-sg"
  }
}

# ────────────────────────────────────────────────────────────────
# 2. BASTION HOST SECURITY GROUP (Public Subnet - Jump Box)
# ────────────────────────────────────────────────────────────────
resource "aws_security_group" "bastion" {
  name        = "infrawave-bastion-sg"
  description = "SSH jump host - only admin IP can connect"
  vpc_id      = aws_vpc.main.id

  # Ingress: ONLY admin SSH access (NO OTHER PORTS)
  ingress {
    description = "SSH from administrator IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]  # 🔒 CRITICAL: NOT 0.0.0.0/0!
  }

  # Egress: Allow SSH to backend instances ONLY
  egress {
    description      = "SSH to backend instances"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = ["10.0.1.0/24"]  # 🔒 Trust by SG, not CIDR
  }

  # Optional: Allow outbound HTTPS for bastion updates
  egress {
    description = "HTTPS for OS updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infrawave-bastion-sg"
  }
}

# ────────────────────────────────────────────────────────────────
# 3. BACKEND EC2 SECURITY GROUP (Private Subnet - API Server)
# ────────────────────────────────────────────────────────────────
resource "aws_security_group" "backend" {
  name        = "infrawave-backend-sg"
  description = "Backend API - only frontend can call + bastion for SSH"
  vpc_id      = aws_vpc.main.id

  # Ingress: API traffic ONLY from frontend instances (SG reference = least privilege)
  ingress {
    description      = "App port from frontend instances only"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    security_groups  = [aws_security_group.frontend.id]  # 🔒 NOT CIDR!
  }

  # Ingress: SSH ONLY from bastion host (SG reference)
  ingress {
    description      = "SSH from bastion host only"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion.id]  # 🔒 NOT CIDR!
  }

  # Egress: Database access to RDS
  egress {
    description      = "PostgreSQL to RDS"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.rds.id]
  }

  # Egress: Allow outbound for OS updates via NAT Gateway
  egress {
    description = "HTTPS for OS updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infrawave-backend-sg"
  }
}

# ────────────────────────────────────────────────────────────────
# 4. RDS POSTGRESQL SECURITY GROUP (Private Subnet - Database)
# ────────────────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "infrawave-rds-sg"
  description = "RDS PostgreSQL - only backend can connect"
  vpc_id      = aws_vpc.main.id

  # Ingress: Database access ONLY from backend instances (SG reference = least privilege)
  ingress {
    description      = "PostgreSQL from backend instances only"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.backend.id]  # 🔒 NOT CIDR!
  }

  # Egress: Minimal outbound (RDS rarely initiates connections)
  egress {
    description = "Allow outbound for RDS maintenance"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infrawave-rds-sg"
  }
}