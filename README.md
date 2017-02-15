# Fovea marathon base

Ansible playbooks to initialize a bare mesos/marathon cluster

## Getting started

Run a test cluster with Vagrant.

```sh
(cd inventory/vagrant; vagrant up)
ansible-playbook -i inventory/vagrant/hosts platform/full.yml
```

## Specific of this install

 * The cluster can be composed of any machines on the internet, they will be connected together by a tinc virtual private network (VPN).
 * Each node have docker installed. Everything then runs inside docker containers.

## Configuration

Your inventory file should list the following groups:

 * `mesos-masters`
   * typically 3 hosts.
   * they'll run mesos masters, zookeeper and marathon.
 * `mesos-slaves`
   * they'll run mesos agents.
   * can be on the same hosts as mesos-masters.
 * `loadbalancers`
   * 2 hosts that'll serve as load-balancers

Following variables have to be defined:

 * `cluster_name` a string naming this cluster
 * `zk_hosts` comma separated list of hostname:port where zookeeper is running
   * usually "<master1>:2181,<master2>:2181,<master3>:2181"
   * _(replace <masterX> by the actual hostnames)_
 * `mesos_masters` space separated list of mesos masters hostnames
   * usually "<master1> <master2> <master3>"
 * `docker_bip` binding interface for docker network
   * usually "172.17.0.1"
 * `ubuntu_version` version of ubuntu running on machines
   * eg: ubuntu-trusty or ubuntu-xenial
 * `ssl_certs` link to SSL certificates used by the load-balancer
   * concatenated PEM certificate and private key (see haproxy doc)

See inventory/vagrant/ for an example setup.
