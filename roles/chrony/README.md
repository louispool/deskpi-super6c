# Role definition for installing [*chrony*](https://chrony.tuxfamily.org/) a local NTP server or client.

```
├── roles
│  ├── chrony
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── handlers 
|  |  |  ├── main.yml  
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── chrony.conf.j2
```

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for setting NTP servers and NTP clients using [*chrony*](https://chrony.tuxfamily.org/), a versatile implementation of the Network Time Protocol (NTP).