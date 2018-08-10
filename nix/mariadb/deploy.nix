let
  pkgs = import ../nixpkgs.nix;

in {
  network = {
    description = "ota-mariadb";
    enableRollback = true;
  };

  mariadb = import ../common.nix // {
    networking.firewall.allowedTCPPorts = [ 22 3306 ];

    services.mysql = {
      package = pkgs.mariadb;
      enable = true;
      dataDir = "/data-db";
    };
  };
}
