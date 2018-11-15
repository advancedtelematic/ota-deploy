{ config ? {}
, system ? "x86_64-linux"
}:

with builtins;

let
  versions = import ./versions.nix;

  nixpkgs = fetchTarball {
    url    = "https://github.com/NixOS/nixpkgs/archive/${versions.nixpkgs.rev}.tar.gz";
    sha256 = versions.nixpkgs.sha256;
  };

  overlayFiles = map (fileName: import (./overlays + ("/" + fileName)))
    (filter (fileName: match ".*\\.nix" fileName != null)
            (attrNames (readDir ./overlays)));

  overlays = overlayFiles ++ [
    (self: super: {
      inherit nixpkgs;
      fetchRepo = repo:
        super.fetchFromGitHub { inherit (versions."${repo}") owner repo rev sha256; };
    })
  ];

  pkgs = import nixpkgs { inherit config system overlays; };

in pkgs
