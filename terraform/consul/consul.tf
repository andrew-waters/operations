variable "ssh_key" {}
variable "region" {}
variable "image" {}
variable "size" {}
variable "count" {}

resource "digitalocean_droplet" "consul" {
  ssh_keys           = ["${var.ssh_key}"]
  image              = "${var.image}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true
  name               = "consul-${count.index + 1}"
  count              = "${var.count}"

  connection {
    type        = "ssh"
    private_key = "${file("./.ssh/id_rsa")}"
    user        = "root"
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "${path.module}/../scripts/consul/debian_upstart.conf"
    destination = "/tmp/upstart.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.count} > /tmp/consul-server-count",
      "echo ${digitalocean_droplet.consul.0.ipv4_address} > /tmp/consul-server-addr",
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/../scripts/consul/install.sh",
      "${path.module}/../scripts/consul/service.sh",
    ]
  }
}
