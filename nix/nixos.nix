with import ./nixpkgs.nix;

let
  unpackImage = { image, sha256 }:
    pkgs.runCommand "virtualbox-nixops-${image}.vmdk" { preferLocalBuild = true; allowSubstitutes = false; }
      ''
        xz --decompress < ${pkgs.fetchurl {
          url = "https://nixos.org/releases/nixos/virtualbox-nixops-images/virtualbox-nixops-${image}.vmdk.xz";
          inherit sha256;
        }} > $out
      '';

  baseImage = unpackImage {
    image  = "18.03pre131587.b6ddb9913f2";
    sha256 = "1hxdimjpndjimy40g1wh4lq7x0d78zg6zisp23cilqr7393chnna";
  };

in {
  makeVbox = { cpu, mem }: {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox = {
      vcpu = cpu;
      memorySize = mem;
      headless = true;
      disks.disk1.baseImage = baseImage;
    };
  };
}
