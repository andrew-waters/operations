variable "digitalocean_token" {}
variable "base_image_name" {}

provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

data "digitalocean_image" "nomad" {
  name = "${var.base_image_name}"
}

resource "digitalocean_ssh_key" "root" {
  name       = "nomad agent provisioner"
  public_key = "${file("./.ssh/id_rsa.pub")}"
}

module "servers" {
  source   = "./server"
  region   = "lon1"
  count    = 2
  image    = "${data.digitalocean_image.nomad.image}"
  ssh_keys = "${digitalocean_ssh_key.root.fingerprint}"
}

module "clients" {
  source   = "./client"
  region   = "lon1"
  count    = 2
  image    = "${data.digitalocean_image.nomad.image}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${digitalocean_ssh_key.root.fingerprint}"
}

output "Nomad Servers" {
  value = "${join(" ", split(",", module.servers.addrs))}"
}
