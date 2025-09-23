data "external" "id_rsa" {
  program = ["./prepkey.sh"]
}

# Make a key pair on AWS based on the first local key on your
# development machine
resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = data.external.id_rsa.result["id_rsa"]
}
