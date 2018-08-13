# OTA Deploy

## Getting started

### Installing Nix and NixOps

To install Nix on Linux and macOS, run the following command (ideally after inspecting the script yourself):

```
curl https://nixos.org/nix/install | sh
```

With Nix installed, install NixOps with:

```
nix-env -i nixops
```

### Deploying services

Run `make` without any arguments to see a list of the available options.

By default each service will be deployed to a local VirtualBox image, although you can override the infrastructure target with the `DEPLOY` variable. For example, to deploy Kafka in Azure, use the following command:

`DEPLOY=azure make create-kafka`

This will create a NixOps deployment with the config from two files: `nix/kafka/deploy.nix` and `nix/kafka/azure.nix`.

### Setting up VirtualBox deployments

After installing VirtualBox, ensure you have a host-only network named `vboxnet0` created and DHCP enabled.

### Building Linux packages in macOS

Set up [Remote Builds](https://nixos.org/nix/manual/#chap-distributed-builds) to allow building `x86_64-linux` packages from macOS. Docker can be used for this purpose via the [nix-docker](https://github.com/LnL7/nix-docker#running-as-a-remote-builder) repository.

For a quick-start guide, take a look at [Provisioning a NixOS server from macOS](https://medium.com/@zw3rk/provisioning-a-nixos-server-from-macos-d36055afc4ad).
