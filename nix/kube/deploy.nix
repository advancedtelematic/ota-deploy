with import ../nixpkgs.nix;

{
  network = {
    description = "Kubernetes";
    enableRollback = true;
  };

  defaults.imports = [ ../common.nix ];

  kube = { config, nodes, ... }:
    let
      cluster = import ./cluster.nix {
        inherit config nodes;
        basicAuthFile = pkgs.writeText "users" ''
          kubernetes,admin,0,"system:masters"
        '';
      };

    in {
      imports = [ cluster ];

      services.kubernetes = {
        roles   = ["master" "node"];
        dataDir = "/data-kube";
      };
    };
}
