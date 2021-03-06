 # Operations

 A playground for deploying a Nomad Cluster using terraform and Digital Ocean as a provider.

## Running

Copy `environments/example.json` to `environments/staging.json` and add your Digital Ocean API key.

### Generate an SSH key that can be used by terraform

`make generate-keys`

### Build your base images

Run `make build-consul` && `make build-nomad` from the root of the repo. This will create the custom machine images that will be used when creating the cluster and store them on DO.

### Deploy the infrastructure

Now you have the base image your servers will use you can run a `make plan` and `make apply`.

## Connecting to servers

`ssh -i ./terraform/.ssh/id_rsa root@SERVER_IP_ADDRESS`

## Images

Below is some information about how the machines images that are created should be used when applying via terraform.

### Consul

Data dir: `/var/lib/consul/`
Config dir: `/etc/nomad`
Logs: `/var/log/consul.log`

### Nomad

Data dir: `/var/lib/nomad/`
Data dir: `/etc/nomad`
Logs: `/var/log/nomad.log`
