# OTA Deploy

## Getting started

### Installing Nix and NixOps

To install Nix on Linux and MacOS, first inspect the script then run the following command:

```
$ curl https://nixos.org/nix/install | sh
```

With Nix installed, install NixOps with:

```
$ nix-env -i nixops
```

### Building Linux packages in MacOS

Set up [Remote Builds](https://nixos.org/nix/manual/#chap-distributed-builds) to allow building `x86_64-linux` packages from MacOS. One of the simplest ways to do so is using Docker with the [nix-docker](https://github.com/LnL7/nix-docker#running-as-a-remote-builder) repository.

## Deploying the OTA Services

### Setting up VirtualBox deployments

After installing VirtualBox, ensure you have a host-only network named `vboxnet0` created and DHCP enabled.
