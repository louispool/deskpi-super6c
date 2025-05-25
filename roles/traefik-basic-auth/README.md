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

## Configuration

Configure the name of the BasicAuth Middleware CRD with the variable `k3s_basic_auth_name`:

```yaml
k3s_basic_auth_name: my-basic-auth
```

Configure the namespace where the BasicAuth Middleware should be located via the variable `k3s_basic_auth_namespace`:
```yaml
k3s_basic_auth_namespace: some-namespace
```

Configure the user and password for the BasicAuth middleware via the variables `basic_auth_user` and `basic_auth_passwd`:
```yaml
basic_auth_user: admin
basic_auth_passwd: passwd
```

## Usage

To use this Role, you typically include it in your Ansible playbook, and set the variables as needed. For example:

```yaml
- ansible.builtin.set_fact:
    my_basic_auth: "my-basic-auth"

- name: Create BasicAuth credentials for the Longhorn dashboard
  include_role:
    name: traefik-basic-auth
  vars:
    k3s_basic_auth_namespace: "{{ my_namespace }}"
    k3s_basic_auth_name: "{{ my_basic_auth }}"
    basic_auth_user: "{{ my_basic_auth_user }}"
    basic_auth_passwd: "{{ my_basic_auth_passwd }}"
```

This will create a BasicAuth middleware in the specified namespace with the provided user and password, which can then be used to protect your Traefik Ingress Routes,
for example:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: my-route
  namespace: "{{ my_namespace }}"
spec:
  entryPoints:
    - web
  routes:
    - kind: Rule
      match: Host(`example.com`)
      services:
        - name: my-service
          port: 80
      middlewares:
        - name: "{{ my_basic_auth }}"
          namespace: "{{ my_namespace }}"
```


