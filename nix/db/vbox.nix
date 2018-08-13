let
  nixos = import ../nixos.nix;

in {
  db = nixos.makeVbox { cpu = 2; mem = 2048; };
}
