variable "count" {}
variable "image" {}
variable "region" {}
variable "size" {}
variable "servers" {
  type = "list"
}
variable "ssh_key" {}

resource "digitalocean_droplet" "client" {
  image    = "${var.image}"
  name     = "nomad-client-${count.index}"
  count    = "${var.count}"
  size     = "${var.size}"
  region   = "${var.region}"
  ssh_keys = ["${var.ssh_key}"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("./.ssh/id_rsa")}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /etc/nomad/server.json <<EOF

{
    "datacenter": "${var.region}",
    "data_dir": "/var/lib/nomad",
    "client": {
        "servers": ${jsonencode(formatlist("%s:%s", var.servers, "4647"))},
        "enabled": true
    }
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
