{ pkgs ? import ../nixpkgs {}
, cpu ? 4
, mem ? 8192
}:

let
  common   = import ./common.nix {};
  images   = import ../images {};
  services = import ../services {};

in {
  network.description = "OTA QEMU";

  qemu = {
    imports = [
      common
      services.cassandra
      services.kafka
      services.kubernetes
      services.mariadb
      services.zookeeper
    ];

    deployment.targetEnv = "libvirtd";
    deployment.libvirtd = {
      vcpu       = cpu;
      memorySize = mem;
      headless   = true;
      baseImage  = images.qcowImage;
      extraDevicesXML = ''
        <graphics type='vnc' port='-1' autoport='yes'/>
      '';
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
