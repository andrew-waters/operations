variable "count" {}
variable "image" {}
variable "region" {}
variable "size" { default = "s-1vcpu-1gb" }
variable "ssh_keys" {}

resource "digitalocean_droplet" "server" {
  image    = "${var.image}"
  name     = "nomad-server-${var.region}-${count.index}"
  count    = "${var.count}"
  size     = "${var.size}"
  region   = "${var.region}"
  ssh_keys = ["${split(",", var.ssh_keys)}"]

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
    bootstrap_expect = 1
}
advertise {
    rpc = "${self.ipv4_address}:4647"
    serf = "${self.ipv4_address}:4648"
}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = "nohup nomad agent -server -config=/etc/nomad -config /var/lib/nomad"
  }
}

resource "null_resource" "server_join" {
  provisioner "local-exec" {
    command = <<CMD
join() {
  curl -X PUT ${digitalocean_droplet.server.0.ipv4_address}:4646/v1/agent/join?address=$1
}
join ${digitalocean_droplet.server.1.ipv4_address}
join ${digitalocean_droplet.server.2.ipv4_address}
CMD
  }
}

output "addrs" {
  value = "${join(",", digitalocean_droplet.server.*.ipv4_address)}"
}
