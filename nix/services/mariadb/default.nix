{ pkgs ? import ../../nixpkgs {}
, dataDir ? "/data-mariadb"
, ensureDatabases ? []
}:

let
  permissions = name: { inherit name; ensurePermissions = { "${name}.*" = "ALL PRIVILEGES"; }; };
  ensureUsers = map permissions ensureDatabases;

in {
  services.mysql = {
    enable  = true;
    package = pkgs.mariadb;
    inherit dataDir ensureDatabases ensureUsers;
  };
}
