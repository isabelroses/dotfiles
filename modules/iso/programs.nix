{ pkgs, config, ... }:
{
  # needed packages for the installer
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      vim # we are not installing neovim here so we have a light dev environment
      pciutils # going to need this for lspci
      gitMinimal # we only need a basic git install
      ;

    installer = pkgs.callPackage ./installer.nix { nix = config.nix.package; };
  };

  # provide all hardware drivers, including proprietary ones
  hardware.enableRedistributableFirmware = true;
}
