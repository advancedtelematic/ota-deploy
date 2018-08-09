{ configPath ? ./config.json }:

let
  system = "x86_64-linux";
  api = import ../../default.nix { inherit system; };
  pkgs = import ../../common.nix { inherit system; };

  kafkaConfig = builtins.fromJSON (builtins.readFile configPath);
  kafkaNodes = map makeNode kafkaConfig.nodes;

  nodeCount = builtins.length kafkaNodes;
  replicationFactor = builtins.toString (if nodeCount < 3 then nodeCount else 3);

  makeNode = node: {
    name = node.name;
    value = { lib, ... }: {
      nixpkgs.system = system;

      networking.firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 22 2181 2888 3888 ];
      };

      services.openssh.enable = true;

      services.apache-kafka = {
        enable = true;
        brokerId = node.id;
        hostname = node.name;
        zookeeper = lib.concatStringsSep "," (map (node: node.name) kafkaNodes);
        logDirs = [ "/data-kafka" ];
        extraProperties = ''
          offsets.topic.replication.factor = ${replicationFactor}
        '';
      };

      services.zookeeper = {
        enable = true;
        id = node.id;
        dataDir = "/data-zk";
        servers =
          let toLine = n: x: "server.${toString (builtins.sub n 1)}=${x.name}:2888:3888\n";
          in lib.concatImapStrings toLine kafkaNodes;
      };
    };
  };

in {
  network = {
    description = "ota-kafka-zk";
    enableRollback = true;
  };
}

// builtins.listToAttrs kafkaNodes
