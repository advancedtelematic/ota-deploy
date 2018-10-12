{ pkgs ? import ../../nixpkgs {}
, dataDir ? "/data-mariadb"
, databases ? [
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
] }:

let
  grantAll = name: { inherit name; ensurePermissions = { "${name}.*" = "ALL PRIVILEGES"; }; };

in {
  services.mysql = {
    inherit dataDir;
    package = pkgs.mariadb;
    enable  = true;

    ensureDatabases = databases;
    ensureUsers     = map grantAll databases;
  };
}
