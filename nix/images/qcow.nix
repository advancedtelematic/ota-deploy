{ pkgs ? import ../nixpkgs {}
, lib ? pkgs.lib
, system ? "x86_64-linux"
, diskSize ? 20*1024
, format ? "qcow2"
}:

let
  configuration = {
    imports = [ "${pkgs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix" ];

    boot = {
      initrd = {
        availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
        kernelModules          = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
        postDeviceCommands     = ''
          hwclock -s
        '';
      };

      growPartition = true;
      loader.grub.device = "/dev/vda";
      loader.timeout = 0;
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
    };

    security.rngd.enable = false;
  };

  nixos = import "${pkgs.nixpkgs}/nixos" { inherit system configuration; };
  image = import "${pkgs.nixpkgs}/nixos/lib/make-disk-image.nix" {
    inherit pkgs lib diskSize format;
    inherit (nixos) config;
  };

in pkgs.stdenv.mkDerivation rec {
  name = "nixos-qemu-${version}";
  version = nixos.config.system.stateVersion;
  nativeBuildInputs = [ image ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp ${image}/nixos.qcow2 $out/disk.qcow2
    sha256sum $out/disk.qcow2 > $out/disk.qcow2.sha256
  '';
}
