let
  pkgs = import ../nixpkgs.nix;

in {
  network = {
    description = "ota-cassandra";
    enableRollback = true;
  };

  cassandra = { config, ... }:
    import ../common.nix //
    {
      networking.firewall.allowedTCPPorts = [ 22 9042 ];

      services.cassandra = {
        enable = true;
        listenAddress = "${config.networking.privateIPv4}";
      };
    };
}
