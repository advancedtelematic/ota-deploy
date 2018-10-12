{ pkgs ? import ../nixpkgs {}
, system ? "x86_64-linux"
}:

let
  vmdk = pkgs.callPackage ./vmdk.nix { inherit system; };
  vmdkImage = "${vmdk}/nixos.vmdk";

in {
  inherit vmdk vmdkImage;
}
