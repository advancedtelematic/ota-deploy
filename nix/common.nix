{
  i18n.defaultLocale = "en_US.UTF-8";

  networking.firewall = {
    enable    = true;
    allowPing = true;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  };
}
