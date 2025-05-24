# Role definition for undoing Dynamic DNS for [AWS Route53](https://aws.amazon.com/route53/)

```
├── roles
│  ├── route53-ddns-uninstall
|  |  ├── tasks 
|  |  |  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles)
for undoing Dynamic DNS for [AWS Route53](https://aws.amazon.com/route53/).

This role removes the cronjob and script that updates Route53 DNS records, and deletes **all** managed policies attached to the user.
