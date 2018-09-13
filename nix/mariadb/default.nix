{ dbImage
, dbDataDir ? "/data-mariadb"
, cassandraDataDir ? "/data-cassandra"
}:

with import ../nixpkgs.nix;

let
  databases = [
    "auditor"
    "builder"
    "campaigner"
    "crypt_vault"
    "device_registry"
    "director"
    "sota_core"
    "treehub"
    "tuf_keyserver"
    "tuf_reposerver"
    "user_profile"
  ];

  grantAll = name: { inherit name; ensurePermissions = { "${name}.*" = "ALL PRIVILEGES"; }; };

in {
  networking.firewall.allowedTCPPorts = [ 22 3306 9042 ];

  services.mysql = {
    package = pkgs.mariadb;
    enable  = true;
    dataDir = dbDataDir;

    ensureDatabases = databases;
    ensureUsers     = map grantAll databases;
  };

  services.cassandra = {
    package = pkgs.cassandra;
    enable  = true;
    homeDir = cassandraDataDir;
  };
} // dbImage
