let
  commit  = "949bddfae38a613a0e8b0931e48ea5d843c1cf71";
  nixpkgs = builtins.fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
    sha256 = "14lbj6qdgga548k7x610an34c91204dmhcz0c5lc9viry184x0l7";
  };

  config = {
    allowUnfree = true;
  };

  overlays = [
    (newPkgs: oldPkgs: {})
  ];

in import nixpkgs { inherit config overlays; system = "x86_64-linux"; }
