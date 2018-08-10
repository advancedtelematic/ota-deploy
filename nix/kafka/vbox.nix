with builtins;

let
  vbox = import ../vbox.nix;
  conf = fromJSON (readFile ./config.json);

  makeVbox = node: {
    name = node.name;
    value = vbox.makeImage 2 2048;
  };
  nodes = map makeVbox conf.nodes;

in listToAttrs nodes
