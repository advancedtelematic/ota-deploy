let
  nixos = import ../nixos.nix;
  image = nixos.makeVbox { cpu = 2; mem = 4096; };

in {
  kube = { ... }: {
    services.flannel.iface = "enp0s8";
  } // image;
}
