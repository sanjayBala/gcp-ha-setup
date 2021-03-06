#### Please follow this guide to setup
Does the following:
A simple HAProxy LB setup with 2 Ngnix Server - created with terraform, configured using ansible and validation using inspec.

Can be configured as sticky or round-roubin.

Displays which backend server you are seeing.

Creates a DNS Zone and a DNS Entry in GCP Cloud DNS.

Validation of Infra using Check Inspec

## Requirements:
    GCP Trial Account
    Terraform v0.13.5
    Ansible 2.10.3
    Chef Inspec 4.23
    Git - To Clone this Git Repo

## Steps to setup
0. Login to GCP Console, create a new project, update the project id in `terraform/provider.tf`.

1. Create a Service account with Project-Owner Role and download it as a JSON, save it as `terraform/service-account.json`.

2. Enable `Compute API`, `Cloud DNS API` from GCP console for the service account created in Step 1.

3. Update the metadata block in `terraform/main.tf` to reflect to your username and key.

4. For ansible, you may need to specify your private key in `ansible/ansible.cfg` if you are not using the one at `~/.ssh/id_rsa.pub`.

Initial Setup is done

## Triggering terraform

0. Change make_sticky in `terraform/terraform.tfvars` to `False` to setup LB without Sticky Sessions/Cookie.

1. Change dir into `terraform` folder, and run terraform init, terraform plan and terraform apply.

2. Terraform creates the ansible inventory file `dev.txt` referenced in `ansible/ansible.cfg`.

3. Once done, the IPs will be printed via terraform, please hit that via curl or your browser.

4. If you have enabled make_sticky, you can see the sticky cookie in Dev Tools.

## Running Inspec

(Note I have already run `inspec init profile --platform gcp my-profile`)

1. Using the Json credentials file from GCP, export the path.
`Eg export GOOGLE_APPLICATION_CREDENTIALS='/Users/sanjaybalaji/Desktop/Alation/gcp-ha-setup/terraform/service-account.json`

2. Run `inspec detect -t gcp://` to make sure you are able to connect to gcp.
You should see some meta info being printed.

3. Cd into `inspect/my-profile` and run this command `inspec exec . -t gcp:// --input-file attributes.yml`

4. Feel free to modify the `inspec/my-profile/attributes.yml` file as per your config.


## HAProxy and Nginx Configuration

The conf files for these servers are stored in `ansible` folder.
I am using placeholders starting with `REPLACE` and passing in required information from terraform to trigger ansible.

Similarly, the tf var `make_sticky` is passed to the ansible playbook and will be an optional task to enable/disable stickiness during creation of this setup.
