{ pkgs ? import ../nixpkgs {}
, cpu ? 4
, mem ? 8192
}:

let
  common   = import ./common.nix {};
  images   = import ../images {};
  services = import ../services {};

in {
  network.description = "OTA VirtualBox";

  vbox = {
    imports = [
      common
      services.cassandra
      services.kafka
      services.kubernetes
      services.mariadb
      services.zookeeper
    ];

    deployment.targetEnv  = "virtualbox";
    deployment.virtualbox = {
      vcpu       = cpu;
      memorySize = mem;
      headless   = true;
      disks.disk1.baseImage = images.vmdkImage;
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
