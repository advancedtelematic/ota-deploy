{ config
, nodes
, kubeImage
, basicAuthFile ? null
, dataDir ? "/data-kube"
, ...
}:

let
  cluster = import ./cluster.nix { inherit config nodes basicAuthFile; };

in {
  imports = [ cluster ];

  services.flannel.iface = "enp0s8";

  services.kubernetes = {
    inherit dataDir;
    roles = ["master" "node"];
  };
} // kubeImage
