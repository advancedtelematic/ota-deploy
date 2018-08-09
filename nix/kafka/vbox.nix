{ configPath ? ./config.json }:

let
  kafkaConfig = builtins.fromJSON (builtins.readFile configPath);
  vboxNodes = map makeVbox kafkaConfig.nodes;

  makeVbox = node: {
    name = node.name;
    value = { pkgs, ... }: {
      deployment.targetEnv = "virtualbox";

      deployment.virtualbox = {
        vcpu = 2;
        memorySize = 2048;
        headless = true;

        disks.disk1.baseImage = pkgs.runCommand "virtualbox-nixops-18.03.vmdk" { preferLocalBuild = true; allowSubstitutes = false; } ''
          xz -d < ${pkgs.fetchurl {
            url = "https://nixos.org/releases/nixos/virtualbox-nixops-images/virtualbox-nixops-18.03pre131587.b6ddb9913f2.vmdk.xz";
            sha256 = "1hxdimjpndjimy40g1wh4lq7x0d78zg6zisp23cilqr7393chnna";
          }} > $out
        '';
      };
    };
  };

in {}

// builtins.listToAttrs vboxNodes
