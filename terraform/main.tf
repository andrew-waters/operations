variable "CLUSTER_CONSUL_INSTANCE_COUNT" {}
variable "CLUSTER_CONSUL_INSTANCE_REGION" {}
variable "CLUSTER_CONSUL_INSTANCE_SIZE" {}

variable "CLUSTER_NOMAD_SERVER_INSTANCE_COUNT" {}
variable "CLUSTER_NOMAD_SERVER_INSTANCE_REGION" {}
variable "CLUSTER_NOMAD_SERVER_INSTANCE_SIZE" {}

variable "DIGITALOCEAN_API_TOKEN" {}
variable "PACKER_IMAGES_CONSUL_SNAPSHOT_NAME" {}
variable "PACKER_IMAGES_NOMAD_SNAPSHOT_NAME" {}

provider "digitalocean" {
  token = "${var.DIGITALOCEAN_API_TOKEN}"
}

data "digitalocean_image" "nomad" {
  name = "${var.PACKER_IMAGES_NOMAD_SNAPSHOT_NAME}"
}

data "digitalocean_image" "consul" {
  name = "${var.PACKER_IMAGES_CONSUL_SNAPSHOT_NAME}"
}

resource "digitalocean_ssh_key" "root" {
  name       = "nomad agent provisioner"
  public_key = "${file("./.ssh/id_rsa.pub")}"
}

resource "digitalocean_tag" "consul_public" {
  name = "consul_public"
}

resource "digitalocean_tag" "nomad_public" {
  name = "nomad_public"
}

resource "digitalocean_firewall" "consul_ui" {
  name = "consul-ui"

  tags = ["${digitalocean_tag.consul_public.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "8500"
      source_addresses   = ["0.0.0.0/0"]
    }
  ]
}


module "consul" {
  source   = "./consul"
  region   = "${var.CLUSTER_CONSUL_INSTANCE_REGION}"
  size     = "${var.CLUSTER_CONSUL_INSTANCE_SIZE}"
  image    = "${data.digitalocean_image.consul.image}"
  count    = "${var.CLUSTER_CONSUL_INSTANCE_COUNT}"
  ssh_key  = "${digitalocean_ssh_key.root.fingerprint}"
  pub_tag  = "${digitalocean_tag.consul_public.id}"
}

module "servers" {
  source    = "./nomad/server"
  region    = "${var.CLUSTER_NOMAD_SERVER_INSTANCE_REGION}"
  size      = "${var.CLUSTER_NOMAD_SERVER_INSTANCE_SIZE}"
  count     = "${var.CLUSTER_NOMAD_SERVER_INSTANCE_COUNT}"
  image     = "${data.digitalocean_image.nomad.image}"
  ssh_key   = "${digitalocean_ssh_key.root.fingerprint}"
  pub_tag   = "${digitalocean_tag.nomad_public.id}"
  consul_ip = "${module.consul.first_consul_address}"
}

// module "clients" {
//   source   = "./nomad/client"
//   region   = "lon1"
//   count    = 2
//   image    = "${data.digitalocean_image.nomad.image}"
//   servers  = "${module.servers.addrs}"
//   ssh_key  = "${digitalocean_ssh_key.root.fingerprint}"
// }

// output "Nomad Servers" {
//   value = "${join(" ", split(",", module.servers.addrs))}"
// }
