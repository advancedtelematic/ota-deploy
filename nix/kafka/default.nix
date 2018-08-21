{ kafkaImage
, instances
}:

with builtins;
with import ../nixpkgs.nix;
with pkgs.lib;

let
  ids   = range 0 (sub instances 1);
  nodes = map (id: { id=id; name ="kafka-${toString id}"; }) ids;

  makeBroker = node: {
    name  = node.name;
    value = { lib, ... }: {
      networking.firewall.allowedTCPPorts = [ 22 2181 2888 3888 ];

      services.apache-kafka = {
        enable    = true;
        brokerId  = node.id;
        hostname  = node.name;
        zookeeper = concatStringsSep "," (map (node: node.name) nodes);
        logDirs   = [ "/data-kafka" ];
        extraProperties = ''
          offsets.topic.replication.factor = ${toString (if instances < 3 then instances else 3)}
        '';
      };

      services.zookeeper = {
        enable  = true;
        id      = node.id;
        dataDir = "/data-zk";
        servers =
          let configLine = node: "server.${toString node.id}=${node.name}:2888:3888";
          in  concatStringsSep "\n" (map configLine nodes);
      };
    } // kafkaImage;
  };

  brokers = listToAttrs (map makeBroker nodes);

in brokers
