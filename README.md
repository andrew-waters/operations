 # Operations

 A playground for deploying a Nomad Cluster using terraform and Digital Ocean as a provider.

## Running

Copy `environments/example.json` to `environments/staging.json` and add your Digital Ocean API key.

Run `make build-nomad` from the root of the repo. This will create a custom machine image that will be used when creating the cluster. It's based on Ubuntu 18.04 with nomad and docker installed.

Once your snaphot is completed, note the timestamp on the image name (eg `nomad-1531167685`) and add it to the `staging.json` file.

Now you have the base image your servers will use you can run a `make plan` and make apply.
