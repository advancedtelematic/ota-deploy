with builtins;

let
  conf = fromJSON (readFile ./config.json);
  nodes = map makeKafka conf.nodes;
  names = map (node: node.name) conf.nodes;
  instances = length names;

  makeKafka = node: {
    name = node.name;
    value = { lib, ... }: import ../common.nix // {
      networking.firewall.allowedTCPPorts = [ 22 2181 2888 3888 ];

      services.apache-kafka = {
        enable = true;
        brokerId = node.id;
        hostname = node.name;
        zookeeper = lib.concatStringsSep "," names;
        logDirs = [ "/data-kafka" ];
        extraProperties = ''
          offsets.topic.replication.factor = ${toString (if instances < 3 then instances else 3)}
        '';
      };

      services.zookeeper = {
        enable = true;
        id = node.id;
        dataDir = "/data-zk";
        servers =
          let toLine = n: name: "server.${toString (sub n 1)}=${name}:2888:3888\n";
          in lib.concatImapStrings toLine names;
      };
    };
  };

in {
  network = {
    description = "ota-kafka-zk";
    enableRollback = true;
  };
} // listToAttrs nodes
