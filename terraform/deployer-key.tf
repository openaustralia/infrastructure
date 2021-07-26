data "external" "id_rsa" {
  program = ["./prepkey.sh"]
}

# TODO: Change instance keys for all instances to use this
# We can't just change them all at once because it will recreate the instances
# (VERY BAD). Instead we probably want to move over slowly as we upgrade or
# rebuild instances

# Make a key pair on AWS based on the first local key on your
# development machine
resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = data.external.id_rsa.result["id_rsa"]
}
