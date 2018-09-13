{ system ? "x86_64-linux", ... }:

with import ../nixpkgs.nix;

let
  nixpkgs = fetchRepo "nixpkgs";
  nixops  = fetchRepo "nixops";

  machine = import "${nixpkgs}/nixos" {
    inherit system;
    configuration = import "${nixops}/nix/virtualbox-image-nixops.nix";
  };
  ova = machine.config.system.build.virtualBoxOVA;

in pkgs.stdenv.mkDerivation rec {
  name    = "virtualbox-nixops-image-${version}";
  phases  = [ "installPhase" ];
  version = machine.config.system.stateVersion;
  nativeBuildInputs = [ ova ];
  installPhase = ''
    mkdir -p $out
    tar -xf ${ova}/*.ova -C $out
    mv $out/{nixos*,nixos}.vmdk
    sha256sum $out/nixos.vmdk > $out/nixos.vmdk.sha256
  '';
}
