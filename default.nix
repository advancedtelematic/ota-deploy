{ system ? builtins.currentSystem } :

let
  config = {
    packageOverrides = pkgs: rec {};
  };

  pkgs = import ./nixpkgs.nix { inherit config system; };

in {
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.passwordAuthentication = false;

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keyFiles = [ ./keys/insecure_rsa_key.pub ];
  };
}
