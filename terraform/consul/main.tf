variable "count" {}
variable "image" {}
variable "pub_tag" {}
variable "region" {}
variable "ssh_key" {}
variable "size" {}

data "template_file" "consul_config" {

  template = "${file("${path.module}/main.json.tpl")}"

  vars {
    datacenter = "${var.region}"
    count = "${var.count}"
  }

}

resource "digitalocean_droplet" "consul" {

  ssh_keys           = ["${var.ssh_key}"]
  image              = "${var.image}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true
  name               = "consul-${count.index + 1}"
  count              = "${var.count}"
  tags               = ["${var.pub_tag}"]

  connection {
    type        = "ssh"
    private_key = "${file("./.ssh/id_rsa")}"
    user        = "root"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /etc/consul/main.json <<EOF
${data.template_file.consul_config.rendered}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = <<CMD
jq '.bind_addr = "${digitalocean_droplet.consul.0.ipv4_address}"' /etc/consul/main.json > /etc/consul/main.json.tmp
CMD
  }

  provisioner "remote-exec" {
    inline = [
      "mv /etc/consul/main.json.tmp /etc/consul/main.json",
      "sleep 5",
      "sudo systemctl start consul"
    ]
  }

}
