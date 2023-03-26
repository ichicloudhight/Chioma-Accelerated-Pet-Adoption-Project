output "pubsub_1" {
  value = aws_subnet.client1_pub_sn1.id
}

output "pubsub_2" {
  value = aws_subnet.client1_pub_sn2.id
}

output "prvsub_1" {
  value = aws_subnet.client1_prv_sn1.id
}

output "prvsub_2" {
  value = aws_subnet.client1_prv_sn2.id
}