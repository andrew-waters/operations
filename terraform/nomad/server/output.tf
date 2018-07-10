output "nomad_server_addrs" {
  value = "${digitalocean_droplet.server.*.ipv4_address}"
}
