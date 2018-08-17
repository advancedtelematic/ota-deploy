let
  nixos = import ../nixos.nix;
  image = nixos.makeVbox { cpu = 2; mem = 2048; };

in {
  db = { ... }: image;
}
