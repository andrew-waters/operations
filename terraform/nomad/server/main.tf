variable "count" {}
variable "image" {}
variable "region" {}
variable "size" { default = "s-1vcpu-1gb" }
variable "ssh_key" {}

resource "digitalocean_droplet" "server" {
  image    = "${var.image}"
  name     = "nomad-server-${var.region}-${count.index}"
  count    = "${var.count}"
  size     = "${var.size}"
  region   = "${var.region}"
  ssh_keys = ["${var.ssh_key}"]
  private_networking = true

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("./.ssh/id_rsa")}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = <<CMD
mkdir /etc/nomad && cat > /etc/nomad/server.hcl <<EOF

datacenter = "${var.region}"
server {
    enabled = true
    bootstrap_expect = ${var.count}
}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = [
      "nohup nomad agent -server -config=/etc/nomad -config /var/lib/nomad &",
      "exit 0"
    ]
  }
}

output "addrs" {
  value = "${join(",", digitalocean_droplet.server.*.ipv4_address)}"
}
