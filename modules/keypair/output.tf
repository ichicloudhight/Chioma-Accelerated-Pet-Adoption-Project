output "client1_pub_key" {
  value = aws_key_pair.client1_pub_key.key_name
}

output "prv_key" {
  value = tls_private_key.client1_key.private_key_pem
}
