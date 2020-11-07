#### Please follow this guide to setup

## Requirements:
    GCP Trial Account
    Terraform v0.13.5
    Ansible 2.10.3
    Git - To Clone this Git Repo

## Steps to setup
0. Login to GCP Console, create a new project, update the project id in `terraform/provider.tf`.

1. Create a Service account with Project-Owner Role and download it as a JSON, save it as `/terraform/service-account.json`.

2. Enable `Compute API`, `Cloud DNS API` from GCP console for the service account created in Step 1.

3. Update the metadata block in `terraform/main.tf` to reflect to your username and key.

4. For ansible, you may need to specify your private key in `ansible/ansible.cfg` if you are not using the one at `~/.ssh/id_rsa.pub`.

Initial Setup is done

## Triggering Setup

0. Change make_sticky in `terraform/terraform.tfvars` to `False` to setup LB without Sticky Sessions/Cookie.

1. Cd into `terraform` dir, and run terraform init, terraform plan and terraform apply.

2. Once done, the IPs will be printed via terraform, please hit that via curl or your browser.

3. If you have enabled make_sticky, you can see the sticky cookie in Dev Tools.
