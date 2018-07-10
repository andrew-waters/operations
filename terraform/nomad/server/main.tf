variable "consul_ip" {}
variable "count" {}
variable "image" {}
variable "pub_tag" {}
variable "region" {}
variable "size" {}
variable "ssh_key" {}

resource "digitalocean_droplet" "server" {
  image              = "${var.image}"
  name               = "nomad-server-${count.index}"
  count              = "${var.count}"
  size               = "${var.size}"
  region             = "${var.region}"
  ssh_keys           = ["${var.ssh_key}"]
  tags               = ["${var.pub_tag}"]
  private_networking = true

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("./.ssh/id_rsa")}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /etc/nomad/server.hcl <<EOF

datacenter = "${var.region}"
data_dir = "/var/lib/nomad"
server {
    enabled = true
    bootstrap_expect = ${var.count}
}

consul {
  address = "${var.consul_ip}:8500"
}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start nomad"
    ]
  }
}

output "addrs" {
  value = "${join(",", digitalocean_droplet.server.*.ipv4_address)}"
}
