output "first_consul_address" {
  value = "${digitalocean_droplet.consul.0.ipv4_address}"
}

output "all_consul_addresses" {
  value = ["${digitalocean_droplet.consul.*.ipv4_address}"]
}
