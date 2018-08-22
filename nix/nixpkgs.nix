with builtins;

let
  version = fromJSON (readFile ../nixpkgs.json);
  nixpkgs = fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${version.commit}.tar.gz";
    sha256 = version.sha256;
  };

  config.allowUnfree = true;
  pkgs = import nixpkgs { inherit config; system = "x86_64-linux"; };

in pkgs
