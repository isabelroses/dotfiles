{ pkgs, self', ... }:
{
  # disable all installer tools and only bring the ones that we explicitly need
  # for installing or debugging
  system = {
    disableInstallerTools = true;

    tools = {
      nixos-enter.enable = true;
      nixos-install.enable = true;
      nixos-generate-config.enable = true;
    };
  };

  # needed packages for the installer
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      vim # we are not installing neovim here so we have a light dev environment
      pciutils # going to need this for lspci
      gitMinimal # we only need a basic git install
      ;

    inherit (self'.packages) iztaller;
  };

  # provide all hardware drivers, including proprietary ones
  hardware.enableRedistributableFirmware = true;
}
