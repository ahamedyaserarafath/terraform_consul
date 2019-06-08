
 resource "aws_security_group" "consul_server_security_group_closed" {
  name        = "${var.name}_sg_internal"
  description = "Security group managed for consul"

  vpc_id = "${aws_vpc.consul_server_vpc.id}"
  tags = {
    Name = "${var.name}_sg_internal"
    Environment = "${var.env}"
  }
}

resource "aws_security_group_rule" "consul_server_security_group_rule_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All egress traffic"
  security_group_id = "${aws_security_group.consul_server_security_group_closed.id}"
}

resource "aws_security_group_rule" "consul_server_security_group_rule_ingress_tcp" {
  count             = "${var.consul_server_security_group_closed_port == "default_null" ? 0 : length(split(",",var.consul_server_security_group_closed_port))}"
  type              = "ingress"
  from_port         = "${element(split(",", var.consul_server_security_group_closed_port), count.index)}"
  to_port           = "${element(split(",", var.consul_server_security_group_closed_port), count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.consul_server_vpc_cidr}"]
  description       = ""
  security_group_id = "${aws_security_group.consul_server_security_group_closed.id}"
}

resource "aws_security_group_rule" "consul_server_security_group_rule_ingress_udp" {
  count             = "${var.consul_server_security_group_closed_port == "default_null" ? 0 : length(split(",",var.consul_server_security_group_closed_port))}"
  type              = "ingress"
  from_port         = "${element(split(",", var.consul_server_security_group_closed_port), count.index)}"
  to_port           = "${element(split(",", var.consul_server_security_group_closed_port), count.index)}"
  protocol          = "udp"
  cidr_blocks       = ["${var.consul_server_vpc_cidr}"]
  description       = ""
  security_group_id = "${aws_security_group.consul_server_security_group_closed.id}"
}

resource "aws_security_group" "consul_server_security_group_open" {
 name        = "${var.name}_sg_external"
 description = "Security group managed for consul for external "

 vpc_id = "${aws_vpc.consul_server_vpc.id}"
 tags = {
   Name = "${var.name}_sg_external"
   Environment = "${var.env}"
 }
}

resource "aws_security_group_rule" "consul_server_security_group_rule_egress_open" {
 type              = "egress"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 description       = "All egress traffic"
 security_group_id = "${aws_security_group.consul_server_security_group_open.id}"
}

resource "aws_security_group_rule" "consul_server_security_group_rule_ingress_tcp_open" {
 count             = "${var.consul_server_security_group_open_port == "default_null" ? 0 : length(split(",",var.consul_server_security_group_open_port))}"
 type              = "ingress"
 from_port         = "${element(split(",", var.consul_server_security_group_open_port), count.index)}"
 to_port           = "${element(split(",", var.consul_server_security_group_open_port), count.index)}"
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 description       = ""
 security_group_id = "${aws_security_group.consul_server_security_group_open.id}"
}
