# Terraform Traefik Example

This repo provides an example build of a WordPress server on Azure via Terraform, utilizing Docker and Traefik to automate the deployment.

## Usage

(Assuming Terraform is installed)

1. Have an Azure account
2. Register a domain
3. Create an Azure DNS Zone
4. Create an Azure Resource Group to contain your assets
5. Point your domain to Azure's DNS servers, as described in the DNS Zone.
6. Review the `.tf` files and the `docker-compose.yml` file for domain, email, and resource group details, changing everything to appropriate values.
7. `terraform init`
8. `terraform apply`. Supply your external IP for SSH access, and a password of your choosing for the VM.

