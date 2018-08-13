with builtins;

let
  version = fromJSON (readFile ../nixpkgs.json);
  nixpkgs = fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${version.commit}.tar.gz";
    #FIXME: sha256 = version.sha256;
  };

  config = {
    allowUnfree = true;
  };

  overlays = [
    (newPkgs: oldPkgs: {})
  ];

in import nixpkgs { inherit config overlays; system = "x86_64-linux"; }
