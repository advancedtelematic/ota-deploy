# OTA Deploy

## Getting started

### Installing Nix and NixOps

To install Nix on Linux and MacOS, first inspect the script then run the following command:

```
curl https://nixos.org/nix/install | sh
```

With Nix installed, install NixOps with:

```
nix-env -i nixops
```

### Building Linux packages in macOS

Set up [Remote Builds](https://nixos.org/nix/manual/#chap-distributed-builds) to allow building `x86_64-linux` packages from macOS. Docker can be used for this purpose via the [nix-docker](https://github.com/LnL7/nix-docker#running-as-a-remote-builder) repository.

For a quick-start guide, take a look at [Provisioning a NixOS server from macOS](https://medium.com/@zw3rk/provisioning-a-nixos-server-from-macos-d36055afc4ad).

## Deploying the OTA Services

### Setting up VirtualBox deployments

After installing VirtualBox, ensure you have a host-only network named `vboxnet0` created and DHCP enabled.
