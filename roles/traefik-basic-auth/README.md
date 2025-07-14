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

## Synopsis

This role does the following:

1. Creates a secret in the specified namespace containing the BasicAuth credentials.
2. Creates a BasicAuth Middleware Custom Resource Definition (CRD) in the specified namespace using the secret created.
3. Sets the facts `basic_auth_secret_name` and `basic_auth_middleware_name` for use in subsequent tasks or roles.

## Configuration

Configure the namespace to create the BasicAuth secret and middleware in, via the variable `basic_auth_namespace`:
```yaml
basic_auth_namespace: some-namespace
```

Configure the name of the BasicAuth Middleware CRD with the variable `basic_auth_name`:
```yaml
basic_auth_name: my-basic-auth
```
The name of the secret created will be `basic_auth_name` suffixed with `-secret`, so in this case it will be `my-basic-auth-secret`.

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

- name: Create BasicAuth credentials
  include_role:
    name: traefik-basic-auth
  vars:
    basic_auth_namespace: "{{ my_namespace }}"
    basic_auth_name: "{{ my_basic_auth }}"
    basic_auth_user: "{{ my_basic_auth_user }}"
    basic_auth_passwd: "{{ my_basic_auth_passwd }}"
```

This will create a BasicAuth middleware and Secret in the specified namespace with the provided user and password, which can then be used to protect your Traefik Ingress Routes.

The role sets the facts `basic_auth_secret_name` and `basic_auth_middleware_name` for use in subsequent tasks or roles.

For example:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: my-route
  namespace: "{{ basic_auth_namespace }}"
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
        - name: "{{ basic_auth_middleware_name }}"
          namespace: "{{ basic_auth_namespace }}"
```


