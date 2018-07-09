build-nomad:
	cd ./packer/nomad && packer build -var-file=../../environments/staging.json ./build.json

plan:
	cd ./terraform && terraform plan -var-file=../environments/staging.json -out ./plan

apply:
	cd ./terraform && terraform apply -var-file=../environments/staging.json

destroy:
	cd ./terraform && terraform destroy -var-file=../environments/staging.json

init:
	cd ./terraform && terraform init -var-file=../environments/staging.json

generate-keys:
	ssh-keygen -t rsa -b 4096 -P "" -C root@somewhere -f ./terraform/.ssh/id_rsa
