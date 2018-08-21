with import ../nixpkgs.nix;

{
  network = {
    description = "MariaDB & Cassandra";
    enableRollback = true;
  };

  defaults.imports = [ ../common.nix ];

  db = { config, ... }: {
    networking.firewall.allowedTCPPorts = [ 22 3306 9042 ];

    services.mysql = {
      package = pkgs.mariadb;
      enable  = true;
      dataDir = "/data-db";
    };

    services.cassandra = {
      package = pkgs.cassandra;
      enable  = true;
      homeDir = "/data-cassandra";
    };
  };
}
