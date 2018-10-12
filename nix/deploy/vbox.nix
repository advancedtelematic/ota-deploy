{ pkgs ? import ../nixpkgs {}
, cpu ? 4
, mem ? 8192
}:

let
  inherit (pkgs) writeText;

  images = import ../images {};
  common = import ./common.nix {};

  cassandra = import ../services/cassandra {};
  mariadb   = import ../services/mariadb {};
  kafka     = import ../services/kafka {};
  zookeeper = import ../services/zookeeper {};

  kube = { config, nodes, ... }:
    let basicAuthFile = writeText "users" ''kubernetes,admin,0,"system:masters"'';
    in  import ../services/kubernetes { inherit config nodes basicAuthFile; };

in {
  network = {
    description = "VirtualBox OTA Deployment";
    enableRollback = true;
  };

  vbox = {
    imports = [ common cassandra mariadb kafka zookeeper kube ];

    deployment.targetEnv  = "virtualbox";
    deployment.virtualbox = {
      vcpu       = cpu;
      memorySize = mem;
      headless   = true;
      disks.disk1.baseImage = images.vmdkImage;
    };

    networking.firewall.allowedTCPPorts = [ 22 3306 9042 ];
  };
}
