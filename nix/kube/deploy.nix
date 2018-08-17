let
  pkgs = import ../nixpkgs.nix;

in {
  network = {
    description = "Kubernetes";
    enableRollback = true;
  };

  defaults.imports = [ ../common.nix ];

  kube = { config, nodes, ... }:
    let
      kubernetes = import ./kubernetes.nix {
        inherit config nodes;
        basicAuthFile = pkgs.writeText "users" ''
          kubernetes,admin,0,"system:masters"
        '';
      };

    in {
      imports = [ kubernetes ];

      services.kubernetes = {
        roles   = ["master" "node"];
        dataDir = "/data-kube";
      };
    };
}
