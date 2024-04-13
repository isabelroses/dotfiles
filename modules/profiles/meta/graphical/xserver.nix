{pkgs, ...}: {
  services.xserver = {
    enable = false;
    displayManager.gdm.enable = false;
    displayManager.lightdm.enable = false;

    excludePackages = [
      pkgs.xterm
    ];
  };
}
