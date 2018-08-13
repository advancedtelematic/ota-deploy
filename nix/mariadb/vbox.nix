let
  nixos = import ../nixos.nix;

in {
  mariadb = nixos.makeVbox { cpu = 2; mem = 1024; };
}
