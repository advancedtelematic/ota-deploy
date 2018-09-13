{ system ? "x86_64-linux", ... }:

with import ../nixpkgs.nix;

let
  vmdk = pkgs.callPackage ./vmdk.nix { inherit system; };

in {
  makeVbox = { cpu, mem }: {
    deployment.targetEnv  = "virtualbox";
    deployment.virtualbox = {
      vcpu       = cpu;
      memorySize = mem;
      headless   = true;
      disks.disk1.baseImage = "${vmdk}/nixos.vmdk";
    };

    nixpkgs.localSystem.system = system;
  };
}
