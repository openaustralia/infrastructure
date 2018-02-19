resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "standard security group for webservers. Allow ssh/http/https"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow pings from hosts on the internet
  ingress {
    protocol = "icmp"
    from_port = 8
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_security_group" "default" {
  name = "default"
}

# TODO: Once the 3306 port is removed we probably want to remove this security group
# and just use the standard webserver security group above
resource "aws_security_group" "theyvoteforyou" {
  name        = "theyvoteforyou"
  description = "theyvoteforyou security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow pings from hosts on the internet
  ingress {
    protocol = "icmp"
    from_port = 8
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: Remove this once migration is complete and we don't
  # need the ssh tunnel running on theyvoteforyou
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${data.aws_security_group.default.id}"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "main_database" {
  name        = "main_database"
  description = "main database security group"

  # TODO: Limit ingoing and outgoing traffic to within our vpc
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jamison" {
  # TODO Change this
  description = "launch-wizard-3 created 2018-02-19T05:58:53.596+11:00"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow pings from hosts on the internet
  ingress {
    protocol = "icmp"
    from_port = 8
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "octopus" {
  # TODO Change this
  description = "for main instance"
  
  # TODO: Remove this
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh is running on port 2506
  ingress {
    from_port   = 2506
    to_port     = 2506
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow pings from hosts on the internet
  ingress {
    protocol = "icmp"
    from_port = 8
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow everything going out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
