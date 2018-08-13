with builtins;

let
  nixos = import ../nixos.nix;
  conf  = fromJSON (readFile ./config.json);
  nodes = map makeNode conf.nodes;

  makeNode = node: {
    name  = node.name;
    value = nixos.makeVbox { cpu = 2; mem = 2048; };
  };

in listToAttrs nodes
