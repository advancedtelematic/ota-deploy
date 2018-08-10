let
  vbox = import ../vbox.nix;

in {
  mariadb = vbox.makeImage 2 1024;
}
