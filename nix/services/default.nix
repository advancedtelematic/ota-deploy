{ pkgs ? import ../nixpkgs {}
, kubeUser ? "admin"
, kubePass ? "password"
, ensureDatabases ? [
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
  ]
}:

let
  inherit (pkgs) writeText;

  cassandra = import ./cassandra {};
  mariadb   = import ./mariadb { inherit ensureDatabases; };
  kafka     = import ./kafka {};
  zookeeper = import ./zookeeper {};

  kubernetes = { config, nodes, ... }:
    let basicAuthFile = writeText "users" ''${kubePass},${kubeUser},0,"system:masters"'';
    in  import ../services/kubernetes { inherit config nodes basicAuthFile; };

in {
  inherit cassandra mariadb kafka zookeeper kubernetes;
}
