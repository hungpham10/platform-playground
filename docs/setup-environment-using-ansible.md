# 📘 Guide: Writing and Using `inventory.json` for Ansible

This document explains how to create an **Ansible inventory file in JSON format** (`inventory.json`) to manage and configure instances such as gateways, databases, or application servers.  

---

## 1. Purpose of `inventory.json`
The inventory file tells Ansible:
- Which hosts (servers/VMs) are available.
- How to connect to them (IP/hostname, user, password/SSH args).
- Metadata (roles, domains, networking, custom variables).
- Groupings of hosts (e.g., `database`, `gateway`) for easier targeting.

---

## 2. Basic Structure

An `inventory.json` has two main sections under `all`:
- **hosts** → list of machines with their configuration.  
- **children** → logical groups of hosts (e.g., all DB servers).

Example layout:
```json
{
  "all": {
    "hosts": {
      "<hostname>": {
        "ansible_host": "<ip-or-dns>",
        "ansible_user": "<ssh-username>",
        "ansible_password": "<password-if-needed>",
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
        "instance_role": "<role-name>",
        "network_interfaces": [
          {
            "name": "eth0",
            "type": "ethernet",
            "dhcp": false,
            "addresses": ["<ip-with-cidr>"],
            "gateway": "<gateway-ip>",
            "nameservers": {
              "addresses": ["8.8.8.8", "8.8.4.4"]
            }
          }
        ],
        "domain": "<domain-name>",
        "net": "<network-tag>",
        "custom_var": "value"
      }
    },
    "children": {
      "<group-name>": {
        "hosts": {
          "<hostname>": {}
        }
      }
    }
  }
}
