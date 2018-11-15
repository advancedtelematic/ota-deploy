{ pkgs ? import ../nixpkgs {}
, cpu ? 4
, mem ? 8192
}:

let
  common   = import ./common.nix {};
  images   = import ../images {};
  services = import ../services {};

  getUri = builtins.getEnv "LIBVIRT_DEFAULT_URI";
  URI = if getUri != "" then getUri else "qemu:///system";

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
      baseImage  = images.qcow;

      inherit URI;
      extraDevicesXML = ''
        <graphics type='vnc' port='-1' autoport='yes'/>
      '';
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
