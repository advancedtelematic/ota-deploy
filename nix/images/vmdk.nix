{ pkgs ? import ../nixpkgs {}
, system ? "x86_64-linux"
}:

let
  nixpkgs = pkgs.nixpkgs;
  nixops  = pkgs.fetchRepo "nixops";

  configuration = import "${nixops}/nix/virtualbox-image-nixops.nix";
  nixos = import "${nixpkgs}/nixos" { inherit system configuration; };
  image = nixos.config.system.build.virtualBoxOVA;

in pkgs.stdenv.mkDerivation rec {
  name    = "nixos-vbox-${version}";
  phases  = [ "installPhase" ];
  version = nixos.config.system.stateVersion;
  nativeBuildInputs = [ image ];
  installPhase = ''
    mkdir -p $out
    tar -xf ${image}/*.ova -C $out
    mv $out/{nixos*,nixos}.vmdk
    sha256sum $out/nixos.vmdk > $out/nixos.vmdk.sha256
  '';
}
