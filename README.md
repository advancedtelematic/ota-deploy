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

The default config values applied to all instances can be found at `nix/common.nix`.

In particular, you will want to set `users.root.openssh.authorizedKeys.keyFiles` to a public key for bootstrapping services. By default, this is set to `~/.ssh/id_rsa.pub`.

### Setting up VirtualBox deployments

After installing VirtualBox, ensure you have a host-only network named `vboxnet0` created with DHCP enabled.

### Building Linux packages in macOS

Set up [Remote Builds](https://nixos.org/nix/manual/#chap-distributed-builds) to allow building `x86_64-linux` packages from macOS. Docker can be used for this purpose via the [nix-docker](https://github.com/LnL7/nix-docker#running-as-a-remote-builder) repository.

For a quick-start guide, take a look at [Provisioning a NixOS server from macOS](https://medium.com/@zw3rk/provisioning-a-nixos-server-from-macos-d36055afc4ad).

## Deploying the OTA services

Run `make` without any arguments to see a list of the available deployment targets.

For example, to deploy all OTA services to VirtualBox use the following command:

`make create-vbox`

This will create a NixOps deployment using the definition from `nix/vbox/default.nix`.

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
