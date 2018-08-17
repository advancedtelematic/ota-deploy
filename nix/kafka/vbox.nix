with builtins;

let
  nixos = import ../nixos.nix;
  conf  = fromJSON (readFile ./config.json);

  makeNode = node: { ... }: {
    name  = node.name;
    value = nixos.makeVbox { cpu = 2; mem = 2048; };
  };

  nodes = listToAttrs (map makeNode conf.nodes);

in nodes
