variable "digitalocean_token" {}
variable "consul_num_instances" {}
variable "consul_base_image" {}
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

module "consul" {
  source   = "./consul"
  region   = "lon1"
  size     = "s-1vcpu-1gb"
  image    = "${var.consul_base_image}"
  count    = "${var.consul_num_instances}"
  ssh_key  = "${digitalocean_ssh_key.root.fingerprint}"
}

module "servers" {
  source   = "./nomad/server"
  region   = "lon1"
  count    = 3
  image    = "${data.digitalocean_image.nomad.image}"
  ssh_key  = "${digitalocean_ssh_key.root.fingerprint}"
}

module "clients" {
  source   = "./nomad/client"
  region   = "lon1"
  count    = 2
  image    = "${data.digitalocean_image.nomad.image}"
  servers  = "${module.servers.addrs}"
  ssh_key  = "${digitalocean_ssh_key.root.fingerprint}"
}

output "Nomad Servers" {
  value = "${join(" ", split(",", module.servers.addrs))}"
}
