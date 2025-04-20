# Role definition for installing Traefik's [BasicAuth Middleware](https://doc.traefik.io/traefik/middlewares/http/basicauth/)

```
├── roles
│  ├── traefik-basic-auth
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── basic-auth-middleware.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for configuring Traefik's [BasicAuth Middleware](https://doc.traefik.io/traefik/middlewares/http/basicauth/) using a `user:password` pair.

### Configuration

Configure the name of the BasicAuth Middleware CRD with the variable `k3s_basic_auth_name`:

```yaml
k3s_basic_auth_namespace: basic-auth
```

Configure the namespace where the BasicAuth Middleware should be located via the variable `k3s_basic_auth_namespace`:
```yaml
k3s_basic_auth_namespace: traefik-system
```

Configure the user and password for the BasicAuth middleware via the variables `basic_auth_user` and `basic_auth_passwd`:
```yaml
traefik_basic_auth_user: admin
traefik_basic_auth_passwd: passwd
```