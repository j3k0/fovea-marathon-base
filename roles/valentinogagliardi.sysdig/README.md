Role Name
========

Ansible role to install Sysdig. Sysdig is a system-level exploration tool: capture system state and activity from a running Linux instance, then save, filter and analyze.

Requirements
------------

EPEL Repo

Role Variables
--------------

```yaml

sysdig_repokey: "https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public"

sysdig_url: "http://download.draios.com/stable/rpm/draios.repo"

sysdig_repo: "/etc/yum.repos.d/draios.repo"

sysdig_package: "sysdig"

sysdig_url_apt: "http://download.draios.com/stable/deb/draios.list"

sysdig_repo_apt: "/etc/apt/sources.list.d/draios.list"
```

Dependencies
------------

None

Example Playbook
-------------------------

```
---
- hosts: nodes
  roles:
   - role: sysdig
```

License
-------

GNU General Public License Version 2

Author Information
------------------

Valentino Gagliardi - valentino.g [at] servermanaged.it
