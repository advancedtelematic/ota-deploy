with import ../nixos.nix;
with import ../nixpkgs.nix;
with pkgs.lib;

let
  dbImage    = makeVbox { cpu = 1; mem = 2048; };
  kafkaImage = makeVbox { cpu = 1; mem = 2048; };
  kubeImage  = makeVbox { cpu = 4; mem = 8192; };

  kafkaBrokers = import ../kafka {
    inherit kafkaImage;
    instances = 1;
  };

  makeServers = { ... }: {
    network = {
      description = "VirtualBox OTA Services";
      enableRollback = true;
    };

    defaults.imports = [ ../common.nix ];

    db = import ../mariadb { inherit dbImage; };

    kube = { config, nodes, ... }:
      let
        cluster = import ../kubernetes {
          inherit config nodes kubeImage;
          basicAuthFile = pkgs.writeText "users" ''
            kubernetes,admin,0,"system:masters"
          '';
        };
      in {
        imports = [ cluster ];
      };

  } // kafkaBrokers;

in makeServers
