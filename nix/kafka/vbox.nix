{ instances ? 1 }:

with builtins;
with import ../nixpkgs.nix;
with pkgs.lib;

let
  names = map (id: "kafka-${toString id}") (range 0 (sub instances 1));
  nixos = import ../nixos.nix;

  makeNode = name: {
    name  = name;
    value = nixos.makeVbox { cpu = 2; mem = 2048; };
  };

  nodes = listToAttrs (map makeNode names);

in nodes
