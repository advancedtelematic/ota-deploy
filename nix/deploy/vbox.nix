{ pkgs ? import ../nixpkgs {}
, cpu ? 4
, mem ? 8192
, kubeUser ? "admin"
, kubePass ? "password"
}:

let
  inherit (pkgs) writeText;

  common = import ./common.nix {};
  images = import ../images {};

  cassandra = import ../services/cassandra {};
  mariadb   = import ../services/mariadb {};
  kafka     = import ../services/kafka {};
  zookeeper = import ../services/zookeeper {};

  kube = { config, nodes, ... }:
    let basicAuthFile = writeText "users" ''${kubePass},${kubeUser},0,"system:masters"'';
    in  import ../services/kubernetes { inherit config nodes basicAuthFile; };

in {
  network.description = "VirtualBox OTA Deployment";

  vbox = {
    imports = [ common cassandra mariadb kafka zookeeper kube ];

    deployment.targetEnv  = "virtualbox";
    deployment.virtualbox = {
      vcpu       = cpu;
      memorySize = mem;
      headless   = true;
      disks.disk1.baseImage = images.vmdkImage;
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    systemd.services.apache-kafka = {
      after = [ "zookeeper.service" ];
    };
  };
}
