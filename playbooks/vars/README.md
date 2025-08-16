# Ansible Variables
         
Variables for the Ansible playbooks are stored in this `playbooks/vars` directory. The main configuration file is [`config.yml`](config.yml), and contains all the variables used by the 
playbooks and roles used by those playbooks.

## Ansible Vault

Sensitive data such as passwords, API keys, etc. should be stored in an encrypted file using [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

The playbooks assume a [`playbooks/vars/vault.yml`](playbooks/vars/vault.yml) file exists and is encrypted.

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

This can be done via **one** of the following methods:

##### 1. Prompting for the password:

```shell
ansible-playbook playbooks/k3s-pre-install.yml --ask-vault-pass
```

##### 2. Storing the password in a file and providing the file as an argument:

```shell
ansible-playbook playbooks/k3s-pre-install.yml --vault-password-file ~/.vault_pass.txt
```

##### 3. Setting the `ANSIBLE_VAULT_PASSWORD_FILE` environment variable:

```shell
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
```

##### 4. Setting the `vault_password_file` property in the [`ansible.cfg`](ansible.cfg) file:

```ini
vault_password_file = ./vault_pass.txt
```

### Note

If Ansible fails to parse or decrypt the `vault.yml` file, it will throw an error similar to the following, typically during the "_Include vault variables_" step:

```shell
TASK [Include vault variables] ************************************************************************************************************************************************************************************************************************************************
fatal: [deskpi1]: FAILED! =>
    censored: 'the output has been hidden due to the fact that ''no_log: true'' was specified
        for this result'
    changed: false
```

Frustratingly, you cannot uncensor the output, even if you explicitly set `no_log: false` in the task that includes the `vault.yml` file. Typically, though, this error indicates that there was a problem
accessing or parsing the `vault.yml` file.

To verify this, you can try the following:

1. Ensure that you are able to view and decrypt the `vault.yml` file by running the following command:
```shell
ansible-vault view playbooks/vars/vault.yml
```

2. Dump the contents of the `vault.yml` file to a temporary file and parse it using `yamllint` or `yq`:

```shell
ansible-vault view playbooks/vars/vault.yml > /tmp/vault.yml
yamllint /tmp/vault.yml
````

It should reveal any syntax errors in the `vault.yml` file, such as missing colons, incorrect indentation, or other YAML syntax issues.

As an example, in one personal case, one of the passwords in the `vault.yml` had a backslash (`\`) in it, which is a special character in YAML (and should be escaped with another 
backslash, i.e. `\\`) and this caused the "_Include vault variables_" task to fail.