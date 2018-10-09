{ authorizedKeys ? [ ~/.ssh/id_rsa.pub ] }:

{
  i18n.defaultLocale = "en_US.UTF-8";

  networking.firewall = {
    enable    = true;
    allowPing = true;
  };

  nixpkgs.localSystem.system = "x86_64-linux";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  services.nixosManual.showManual = false;

  system.stateVersion = "18.09";

  time.timeZone = "Europe/Berlin";

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keyFiles = authorizedKeys;
  };
}
