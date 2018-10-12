{ pkgs ? import ../../nixpkgs {}
, dataDir ? "/data-cassandra"
}:

{
  services.cassandra = {
    enable  = true;
    package = pkgs.cassandra;
    homeDir = dataDir;
  };
}
