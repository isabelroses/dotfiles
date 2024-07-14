{ pkgs, ... }:
{
  # needed packages for the installer
  environment.systemPackages = with pkgs; [
    vim # we are not installing neovim here so we have a light dev environment
    pciutils # going to need this for lspci
    gitMinimal # we only need a basic git install
  ];

  # provide all hardware drivers, including proprietary ones
  hardware.enableRedistributableFirmware = true;
}
