with import ../nixpkgs.nix;
with import ../nixos {};
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
    defaults.imports = [ ../common.nix ];
    network = {
      description = "VirtualBox OTA Services";
      enableRollback = true;
    };

    db = import ../mariadb { inherit dbImage; };

    kube = { config, nodes, ... }:
      let
        cluster = import ../kubernetes {
          inherit config nodes kubeImage;
          basicAuthFile = pkgs.writeText "users" ''
            kubernetes,admin,0,"system:masters"
          '';
        };
      in { imports = [ cluster ]; };

  } // kafkaBrokers;

in makeServers
