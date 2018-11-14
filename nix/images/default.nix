{ pkgs ? import ../nixpkgs {}
, system ? "x86_64-linux"
}:

let
  qcow = pkgs.callPackage ./qcow.nix { inherit system; };
  qcowImage = "${qcow}/nixos.qcow2";

  vmdk = pkgs.callPackage ./vmdk.nix { inherit system; };
  vmdkImage = "${vmdk}/nixos.vmdk";

in {
  inherit qcow qcowImage vmdk vmdkImage;
}
