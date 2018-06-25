provider "aws" {
  region     = "${var.region}"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"
}


resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
  public_key = "${file("id_rsa.pub")}"
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpcid}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "appserver1" {
  ami             = "${var.imageid}"
  instance_type   = "${var.instancetype}"
  key_name = "${aws_key_pair.id_rsa.key_name}"
  security_groups = ["${aws_security_group.allow_all.name}"]

  connection {
    user        = "ubuntu"
    private_key = "${file("id_rsa")}"
  }
# This is where we configure the instance with ansible-playbook
    provisioner "local-exec" {
        command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ./id_rsa -i '${aws_instance.appserver1.public_ip},' apache.yml"
    }
 tags {
    Name = "Automation"
  }
}
