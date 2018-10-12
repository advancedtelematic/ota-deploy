{ pkgs ? import ../nixpkgs {}
, system ? "x86_64-linux"
}:

let
  configuration = import "${pkgs.fetchRepo "nixops"}/nix/virtualbox-image-nixops.nix";
  machine = import "${pkgs.tarball}/nixos" { inherit system configuration; };
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
