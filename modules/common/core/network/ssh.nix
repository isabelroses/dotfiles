{
  config,
  lib,
  ...
}: {
  programs.ssh.startAgent = !config.modules.device.yubikeySupport.enable;

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      UseDns = false;
      X11Forwarding = false;
    };

    # the ssh port(s) should be automatically passed to the firewall's allowedTCPports
    openFirewall = true;
    # the port(s) openssh daemon should listen on
    ports = [22];

    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/id_rsa";
        type = "rsa";
      }
    ];
  };
}
