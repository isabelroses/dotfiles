{ pkgs, ... }:
{
  # we need git for flakes
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    lfs.enable = true;
  };

  # needed packages for the installer
  environment.systemPackages = with pkgs; [
    nixos-install-tools
    vim # we are not installing neovim here so we have a light dev environment
    netcat
    pciutils # going to need this for lspci
  ];

  # provide all hardware drivers, including proprietary ones
  hardware.enableRedistributableFirmware = true;
}
