# Below resource is to create public key

resource "tls_private_key" "sskeygen_execution" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Below are the aws key pair
resource "aws_key_pair" "consul_key_pair" {
  depends_on = ["tls_private_key.sskeygen_execution"]
  key_name   = "${var.aws_public_key_name}"
  public_key = "${tls_private_key.sskeygen_execution.public_key_openssh}"
}

resource "aws_instance" "consul_instance" {
  count         = "${length(var.aws_availability_zone)}"
  ami           = "${lookup(var.aws_amis,var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  key_name      = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${aws_security_group.consul_server_security_group_closed.id}","${aws_security_group.consul_server_security_group_open.id}"]
  subnet_id     = "${aws_subnet.consul_server_subnet[count.index].id}"

  connection {
    user        = "ubuntu"
    host = self.public_ip
    private_key = "${tls_private_key.sskeygen_execution.private_key_pem}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt updatefailure",
      "sudo apt -y install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt update",
      "sudo apt -y install docker-ce",
      "sudo mkdir -p /home/ubuntu/consul/data",
      "sudo mkdir -p /home/ubuntu/consul/config",
      "public_ip=$(curl -s 'http://169.254.169.254/latest/meta-data/public-ipv4')",
<<EOT
      if [ "${count.index + 1}" == "1" ];then
        sudo docker run -d \
          --net=host \
          --hostname consul_server_${count.index + 1} \
          --name consul_server_${count.index + 1} \
          --env 'SERVICE_IGNORE=true' \
          --env 'CONSUL_CLIENT_INTERFACE=eth0' \
          --env 'CONSUL_BIND_INTERFACE=eth0' \
          --volume /home/ubuntu/consul/data:/consul/data \
          --volume /home/ubuntu/consul/config:/consul/config \
          --publish 8500:8500 \
          consul:latest \
          consul agent -server -ui -client=0.0.0.0 \
            -bootstrap-expect=3 \
            -advertise="$public_ip" \
            -data-dir='/consul/data'
      else
          sudo docker run -d \
            --net=host \
            --hostname consul_server_${count.index + 1} \
            --name consul_server_${count.index + 1} \
            --env "SERVICE_IGNORE=true" \
            --env "CONSUL_CLIENT_INTERFACE=eth0" \
            --env "CONSUL_BIND_INTERFACE=eth0" \
            --volume /home/ubuntu/consul/data:/consul/data \
            --publish 8500:8500 \
            consul:latest \
            consul agent -server -ui -client=0.0.0.0 \
              -advertise="$public_ip" \
              -retry-join="${aws_instance.consul_instance[0].private_ip}" \
              -data-dir="/consul/data"
      fi
EOT
    ]
  }
  provisioner "local-exec" {
  command = "echo '${tls_private_key.sskeygen_execution.private_key_pem}' >> ${aws_key_pair.consul_key_pair.id}.pem ; chmod 400 ${aws_key_pair.consul_key_pair.id}.pem"
  }
  tags = {
    Name  = "consul_server_${count.index + 1}"
    Environment = "${var.env}"
  }
}
