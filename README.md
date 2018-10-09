# OTA Deploy

## Getting started

### Installing Nix and NixOps

To install Nix on Linux and macOS, run the following command (after inspecting the script yourself):

```
curl https://nixos.org/nix/install | sh
```

With Nix installed, install NixOps with:

```
nix-env -i nixops
```

### Setting deployment configuration values

The default config values applied to all instances can be found at `nix/deploy/common.nix`.

In particular, you will want to set `users.root.openssh.authorizedKeys.keyFiles` to a public key for bootstrapping services. By default, this is set to `~/.ssh/id_rsa.pub`.

### Set up host-only networking

Before deployment, create a host-only VirtualBox network named `vboxnet0` with DHCP:

```
vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1
vboxmanage dhcpserver add --ifname vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0 \
  --lowerip 192.168.56.100 \
  --upperip 192.168.56.200
vboxmanage dhcpserver modify --ifname vboxnet0 --enable
```

### Building Linux packages in macOS

The simplest way to allow building `x86_64-linux` packages from macOS is by installing [linuxkit-builder](https://github.com/nix-community/linuxkit-builder).

Alternatively, you can set up [Remote Builds](https://nixos.org/nix/manual/#chap-distributed-builds) (where a guide can be found at [this blog post](https://medium.com/@zw3rk/provisioning-a-nixos-server-from-macos-d36055afc4ad)).

## Deploying the OTA services

Run `make` without any arguments to see a list of the available deployment targets. To deploy a VirtualBox environment with all OTA services, run the following commands:

```
make vmdk
make create
make deploy
```

This will create a deployment using the definition from `nix/deploy/vbox.nix`. Set the `DEPLOY` environment variable before running `make` commands to select a different definition.

### Setting up kubectl for VirtualBox

To use kubectl from the host, add entries to your `~/.kube/config` (or equivalent) to match the following layout:

```
apiVersion: v1
clusters:
- cluster:
    server: https://**VIRTUALBOX_IP**:443
    insecure-skip-tls-verify: true
  name: nix
contexts:
- context:
    cluster: nix
    user: nix
  name: nix
current-context: nix
kind: Config
preferences: {}
users:
- name: nix
  user:
    password: kubernetes
    username: admin
```

Replace `**VIRTUALBOX_IP**` value with the actual assigned IP.
