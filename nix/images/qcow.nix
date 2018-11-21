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
      growPartition = true;

      initrd.availableKernelModules = [
        "9p"
        "9pnet_virtio"
        "ata_piix"
        "virtio_blk"
        "virtio_net"
        "virtio_pci"
        "virtio_scsi"
      ];

      kernelParams = [ "console=ttyS0" ];

      loader.grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
        extraConfig = ''
          serial; terminal_input serial; terminal_ouput serial
        '';
        forceInstall = true;
      };

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
