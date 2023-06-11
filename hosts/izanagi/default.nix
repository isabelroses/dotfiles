{
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  environment.systemPackages = with pkgs; [
    wslu
    git
  ];

  wsl = {
    enable = true;
    defaultUser = "isabel";
    nativeSystemd = true;
    wslConf.network = {
      hostname = "izanagi";
      generateResolvConf = true;
    };
    startMenuLaunchers = false;
    interop.includePath = false;
  };

  services = {
    dbus.apparmor = "disabled";
    resolved.enable = false;
  };

  networking.hostName = "izanagi";

  security = {
    apparmor.enable = false;
    audit.enable = false;
    auditd.enable = false;
  };

  system.stateVersion = "23.05";
}