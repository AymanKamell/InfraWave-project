# modules/application/key-pair.tf
resource "tls_private_key" "app" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "app" {
  key_name   = "infrawave-app"
  public_key = tls_private_key.app.public_key_openssh

  # Save private key locally (for your SSH access)
  provisioner "local-exec" {
    command = "echo '${tls_private_key.app.private_key_pem}' > ~/.ssh/infrawave-app.pem && chmod 400 ~/.ssh/infrawave-app.pem"
  }
}

# Reference in EC2 config:
key_name = aws_key_pair.app.key_name