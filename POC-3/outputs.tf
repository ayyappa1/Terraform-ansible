
output "appserver1ip" {
  value = "${aws_instance.appserver1.public_ip}"
}


