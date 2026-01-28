# modules/networking/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private-subnet.id
}

output "frontend_sg_id" {
  value = aws_security_group.frontend.id
}

output "backend_sg_id" {
  value = aws_security_group.backend.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}
