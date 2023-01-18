output "vpc_id" {
  value = aws_vpc.main.id
  description = "vpc id"
  sensitive = false
}
output "sub_private_1_id" {
  value = aws_subnet.private_1.id
  description = "private_subnet_id"
}
output "sub_public_1_id" {
  value = aws_subnet.public_1.id
  description = "public_subnet_id" 
}