{ config
, nodes
, domain ? "kubernetes.local"
, authorizationMode ? ["RBAC" "Node"]
, basicAuthFile ? null
, oidc ? {
    issuerUrl     = "https://${domain}/auth/realms/master";
    clientId      = "kubernetes";
    usernameClaim = "email";
    groupsClaim   = "groups";
    groupsPrefix  = "oidc:";
  }
, ...
}:

with builtins;
with import ../nixpkgs.nix;
with pkgs.lib;

let
  masterNames = (filter (hostName: any (role: role == "master")
                                       nodes.${hostName}.config.services.kubernetes.roles)
                        (attrNames nodes));
  masterName = head masterNames;
  masterHost = nodes.${masterName};
  isMaster   = any (role: role == "master") config.services.kubernetes.roles;

  certs = import ./certs.nix {
    externalDomain   = domain;
    serviceClusterIp = "10.0.0.1";
    etcdMasterHosts  = map (hostName: "${hostName}.${domain}") masterNames;
    kubelets         = attrNames nodes;
  };

  kubeconfig = pkgs.writeText "nixops-kubeconfig.json" (toJSON {
    apiVersion = "v1";
    kind = "Config";
    clusters = [{
      name = domain;
      cluster.certificate-authority = "${certs.master}/ca.pem";
      cluster.server = "https://${masterHost.config.networking.privateIPv4}";
    }];
    users = [{
      name = "admin";
      user = {
        client-certificate = "${certs.admin}/admin.pem";
        client-key         = "${certs.admin}/admin-key.pem";
      };
    }];
    contexts = [{
      context = {
        cluster = domain;
        user    = "admin";
      };
      current-context = "admin-context";
    }];
  });

in {
  networking = {
    inherit domain;

    enableIPv6 = false;
    extraHosts = ''
      ${masterHost.config.networking.privateIPv4} api.${domain}
      ${concatMapStringsSep "\n" (hostName:"${nodes.${hostName}.config.networking.privateIPv4} ${hostName}.${domain}") (attrNames nodes)}
    '';

    firewall = let
      ssh     = [ 22 ];
      api     = [ 443 ];
      etcd    = [ 2379 2380 ];
      kubelet = [ 10250 10255 ];
    in {
      allowedTCPPorts   = if isMaster then ssh ++ api ++ etcd ++ kubelet else ssh ++ kubelet;
      trustedInterfaces = [ "docker0" "flannel.1" "zt0" ];
      extraCommands     = concatMapStrings (node: ''
        iptables -A INPUT -s ${node.config.networking.privateIPv4} -j ACCEPT
      '') (attrValues nodes);
    };
  };

  services.etcd = if isMaster then {
    enable              = true;
    certFile            = "${certs.master}/etcd.pem";
    keyFile             = "${certs.master}/etcd-key.pem";
    trustedCaFile       = "${certs.master}/ca.pem";
    peerClientCertAuth  = true;
    listenClientUrls    = ["https://0.0.0.0:2379"];
    listenPeerUrls      = ["https://0.0.0.0:2380"];
    advertiseClientUrls = [
      "https://${config.networking.hostName}.${config.networking.domain}:2379"
    ];
    initialClusterState      = "new";
    initialCluster           = map (hostName: "${hostName}=https://${hostName}.${domain}:2380") masterNames;
    initialAdvertisePeerUrls = [
      "https://${config.networking.hostName}.${config.networking.domain}:2380"
    ];
  } else {};

  environment.variables = {
    ETCDCTL_CERT_FILE = "${certs.worker}/etcd-client.pem";
    ETCDCTL_KEY_FILE  = "${certs.worker}/etcd-client-key.pem";
    ETCDCTL_CA_FILE   = "${certs.worker}/ca.pem";
    ETCDCTL_PEERS     = concatStringsSep "," (map (hostName: "https://${hostName}.${domain}:2379") masterNames);
  };

  services.kubernetes = {
    featureGates   = ["AllAlpha"];
    flannel.enable = true;
    clusterCidr    = "10.1.0.0/16";

    addons = {
      dns = {
        enable = true;
        clusterDomain = "cluster.local";
      };
    };
    verbose = true;

    caFile = "${certs.master}/ca.pem";

    apiserver = if false then {
      advertiseAddress = config.networking.privateIPv4;
      extraOpts        = "--apiserver-count=3 --endpoint-reconciler-type=lease";
    } else {
      advertiseAddress      = masterHost.config.networking.privateIPv4;
      bindAddress           = "0.0.0.0";
      tlsCertFile           = "${certs.master}/kube-apiserver.pem";
      tlsKeyFile            = "${certs.master}/kube-apiserver-key.pem";
      kubeletClientCertFile = "${certs.master}/kubelet-client.pem";
      kubeletClientKeyFile  = "${certs.master}/kubelet-client-key.pem";
      serviceAccountKeyFile = "${certs.master}/kube-service-accounts.pem";
      serviceClusterIpRange = "10.0.0.0/24";
      authorizationMode     = authorizationMode;
      basicAuthFile         = basicAuthFile;
      extraOpts = ''
        --oidc-issuer-url=${oidc.issuerUrl} \
        --oidc-client-id=${oidc.clientId} \
        --oidc-username-claim=${oidc.usernameClaim} \
        --oidc-groups-claim=${oidc.groupsClaim} \
        --oidc-groups-prefix=${oidc.groupsPrefix}
      '';
    };

    etcd = {
      servers  = map (hostName: "https://${hostName}.${domain}:2379") masterNames;
      certFile = "${certs.worker}/etcd-client.pem";
      keyFile  = "${certs.worker}/etcd-client-key.pem";
    };

    kubeconfig = {
      server = "https://api.${config.networking.domain}";
    };

    kubelet = {
      tlsCertFile = "${certs.worker}/kubelet.pem";
      tlsKeyFile  = "${certs.worker}/kubelet-key.pem";
      hostname    = "${config.networking.hostName}.${config.networking.domain}";
      kubeconfig  = {
        certFile = "${certs.worker}/apiserver-client-kubelet-${config.networking.hostName}.pem";
        keyFile  = "${certs.worker}/apiserver-client-kubelet-${config.networking.hostName}-key.pem";
      };
      extraOpts = ''
        --read-only-port=10255
      '';
    };

    controllerManager = {
      serviceAccountKeyFile = "${certs.master}/kube-service-accounts-key.pem";
      kubeconfig = {
        certFile = "${certs.master}/apiserver-client-kube-controller-manager.pem";
        keyFile  = "${certs.master}/apiserver-client-kube-controller-manager-key.pem";
      };
    };

    scheduler = {
      kubeconfig = {
        certFile = "${certs.master}/apiserver-client-kube-scheduler.pem";
        keyFile  = "${certs.master}/apiserver-client-kube-scheduler-key.pem";
      };
    };

    proxy = {
      kubeconfig = {
        certFile = "${certs.worker}/apiserver-client-kube-proxy.pem";
        keyFile  = "${certs.worker}/apiserver-client-kube-proxy-key.pem";
      };
    };
  };
}
