{ config ? {}
, append ? []
, system ? "x86_64-linux"
}:

let
  versions = import ./versions.nix;
  tarball  = builtins.fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${versions.nixpkgs.rev}.tar.gz";
    sha256 = versions.nixpkgs.sha256;
  };

  overlays = [
    (self: super: {
      inherit tarball;

      fetchRepo = repo:
        super.fetchFromGitHub { inherit (versions."${repo}") owner repo rev sha256; };
    })
  ] ++ append;

  pkgs = import tarball { inherit config overlays system; };

in pkgs
