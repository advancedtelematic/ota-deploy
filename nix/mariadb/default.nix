{ dbImage
, dbDataDir ? "/data-mariadb"
, cassandraDataDir ? "/data-cassandra"
}:

with import ../nixpkgs.nix;

{
  networking.firewall.allowedTCPPorts = [ 22 3306 9042 ];

  services.mysql = {
    package = pkgs.mariadb;
    enable  = true;
    dataDir = dbDataDir;

    ensureDatabases = [
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

    ensureUsers = [
      { name = "auditor"; ensurePermissions = { "auditor.*" = "ALL PRIVILEGES"; }; }
      { name = "builder"; ensurePermissions = { "builder.*" = "ALL PRIVILEGES"; }; }
      { name = "campaigner"; ensurePermissions = { "campaigner.*" = "ALL PRIVILEGES"; }; }
      { name = "crypt_vault"; ensurePermissions = { "crypt_vault.*" = "ALL PRIVILEGES"; }; }
      { name = "device_registry"; ensurePermissions = { "device_registry.*" = "ALL PRIVILEGES"; }; }
      { name = "director"; ensurePermissions = { "director.*" = "ALL PRIVILEGES"; }; }
      { name = "sota_core"; ensurePermissions = { "sota_core.*" = "ALL PRIVILEGES"; }; }
      { name = "treehub"; ensurePermissions = { "treehub.*" = "ALL PRIVILEGES"; }; }
      { name = "tuf_keyserver"; ensurePermissions = { "tuf_keyserver.*" = "ALL PRIVILEGES"; }; }
      { name = "tuf_reposerver"; ensurePermissions = { "tuf_reposerver.*" = "ALL PRIVILEGES"; }; }
      { name = "user_profile"; ensurePermissions = { "user_profile.*" = "ALL PRIVILEGES"; }; }
    ];
  };

  services.cassandra = {
    package = pkgs.cassandra;
    enable  = true;
    homeDir = cassandraDataDir;
  };
} // dbImage
