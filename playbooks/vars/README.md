# Ansible Variables
         
Variables for the Ansible playbooks are stored in this `playbooks/vars` directory. The main configuration file is [`config.yml`](config.yml), and contains all the variables used by the 
playbooks and roles used by those playbooks.

## Ansible Vault

Sensitive data such as passwords, API keys, etc. should be stored in an encrypted file using [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

The playbooks assume a [`vault.yml`](vault.yml) file exists and is encrypted.

To create a new encrypted file, run the following command from the project root:

```shell
ansible-vault create playbooks/vars/vault.yml
```
This will open an editor where you can add the sensitive data. Save and close the editor to encrypt the file.

To edit the encrypted file, run the following command from the project root:
```shell
ansible-vault edit playbooks/vars/vault.yml
```
You must provide the vault password when running the playbooks.

This can be done via one the following methods:

##### 1. Prompting for the password:

```shell
ansible-playbook playbooks/k3s-pre-install.yml --ask-vault-pass
```

##### 2. Store the password in a file and provide the file as an argument:

```shell
ansible-playbook playbooks/k3s-pre-install.yml --vault-password-file ~/.vault_pass.txt
```

##### 3. Set the `ANSIBLE_VAULT_PASSWORD_FILE` environment variable:

```shell
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
```