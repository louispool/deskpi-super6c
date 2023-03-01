# [Ansible Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles)

```
├── roles
│  ├── <role-name>
│  |  ├── defaults
|  |  |  ├── main.yml
│  |  ├── files
│  |  |  ├── ...
│  |  ├── handlers
|  |  |  ├── main.yml
│  |  ├── tasks
|  |  |  ├── main.yml
│  |  ├── vars
|  |  |  ├── main.yml
│  |  ├── templates
|  |  |  ├── *.yml.j2
```

This structure houses the roles used by the [Ansible Playbooks](../playbooks/README.md).

## cert-manager-install

