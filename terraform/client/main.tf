variable "count" {}
variable "image" {}
variable "region" {}
variable "size" { default = "s-1vcpu-1gb" }
variable "servers" {}
variable "ssh_keys" {}

data "template_file" "client_config" {
  template = "${path.module}/client.hcl.tpl"
  vars {
    datacenter = "${var.region}"
    servers    = "${split(",", var.servers)}"
  }
}

resource "digitalocean_droplet" "client" {
  image    = "${var.image}"
  name     = "nomad-client-${var.region}-${count.index}"
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
cat > /usr/local/etc/nomad/client.hcl <<EOF
${data.template_file.client_config.rendered}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = "sudo start nomad || sudo restart nomad"
  }
}
