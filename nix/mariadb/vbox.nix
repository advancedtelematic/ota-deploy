with import ../nixos.nix;

{
  db = { ... }: makeVbox { cpu = 2; mem = 2048; };
}
