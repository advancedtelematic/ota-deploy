let
  nixos = import ../nixos.nix;

in {
  cassandra = nixos.makeVbox { cpu = 2; mem = 1024; };
}
