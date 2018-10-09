{ pkgs ? import ../../nixpkgs {}
, id ? 1
, dataDir ? "/data-zookeeper"
, servers ? "server.1=localhost:2888:3888"
}:

{
  services.zookeeper = {
    inherit id dataDir servers;
    enable = true;
  };
}
