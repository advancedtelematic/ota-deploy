{ config
, nodes
, basicAuthFile ? null
, dataDir ? "/data-kube"
}:

let
  cluster = import ./cluster.nix { inherit config nodes basicAuthFile; };
  roles   = [ "master" "node" ];

in {
  imports = [ cluster ];
  services.flannel.iface = "enp0s8";
  services.kubernetes = { inherit dataDir roles; };
}
