# Ansible Inventory

```
├── inventory
│ ├── group_vars
| |  ├── cluster.yml
│ ├── host_vars
│ ├── hosts.yml
```
This structure houses the inventory of hosts in the DeskPi cluster.

### Configuration of the cluster

1. Update the [`hosts.yml`](./hosts.yml) file
    - with the hostnames of the Pi's in your cluster
    - set the IP address octets (the last group of numbers in the IP address) to a range that is unoccupied in your network
2. In the [`cluster.yml`](./group_vars/cluster.yml)
    - set `ansible_user` to the username you defined for your Pi's during the [OS Installation](../README.md#step-2--install-the-os).
   - set `ip_subnet_prefix` to the IP subnet prefix of your network.
   - set `gateway` to the IP address of the gateway in your network.

For example, if `ip_subnet_prefix` in the `config.yml` is defined as follows:

```yaml
ip_subnet_prefix: 192.168.1   
```

and the [`hosts.yml`](./hosts.yml) has the following content:

```yaml
all:
  children:
    cluster:
      children:
        control_plane:
          hosts:
            deskpi1:
              ip_octet: 200
        nodes:
          hosts:
            deskpi2:
              ip_octet: 201
            deskpi3:
              ip_octet: 202
            deskpi4:
              ip_octet: 203
            deskpi5:
              ip_octet: 204
            deskpi6:
              ip_octet: 205
```

Then the master node has the hostname `deskpi1` and the ip address: `192.168.1.200` and the last node in the cluster has the hostname `deskpi6` and the ip address `192.168.1.205`.

### References

- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
- https://www.digitalocean.com/community/tutorials/how-to-set-up-ansible-inventories