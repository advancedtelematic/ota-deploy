{ pkgs ? import ../../nixpkgs {}
, brokers ? 1
, brokerId ? 1
, hostname ? "localhost"
, zookeeperHosts ? [ "localhost" ]
, dataDir ? "/data-kafka"
}:

let
  inherit (builtins) toString;
  inherit (pkgs.lib) concatStringsSep;

  zookeeper = concatStringsSep "," zookeeperHosts;

in {
  services.apache-kafka = {
    inherit brokerId hostname zookeeper;
    enable  = true;
    logDirs = [ dataDir ];
    extraProperties = ''
      offsets.topic.replication.factor = ${toString (if brokers < 3 then brokers else 3)}
      group.max.session.timeout.ms = 60000
      zookeeper.connection.timeout.ms = 60000
    '';
  };

  systemd.services.apache-kafka = {
    after = [ "zookeeper.service" ];
  };
}
