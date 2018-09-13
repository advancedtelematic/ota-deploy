with builtins;

let
  versions = import ./versions.nix;
  nixpkgs  = fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${versions.nixpkgs.rev}.tar.gz";
    sha256 = versions.nixpkgs.sha256;
  };

  config = { allowUnfree = true; };
  native = import nixpkgs { inherit config; };
  system = import nixpkgs { inherit config; system = "x86_64-linux"; };

in rec {
  pkgs = system.pkgs;

  fetchRepo = repo:
    let git = versions."${repo}";
    in  pkgs.fetchFromGitHub { owner = git.owner; repo = git.repo; rev = git.rev; sha256 = git.sha256; };

  shell = native.mkShell {
    buildInputs = [ native.nixops ];
    shellHook   = ''
      export NIX_PATH="nixpkgs=${nixpkgs}:."
    '';
  };
}
