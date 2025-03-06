{
  pkgs,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (self.lib.hardware) ldTernary;
in
{
  programs.nh = {
    enable = true;
    package = inputs'.tgirlpkgs.packages.nh;

    clean = {
      enable = !config.nix.gc.automatic;
      dates = "weekly";
    };
  };

  # WARNING: this leaves you without commands like `nixos-rebuild` which you don't
  # really need, you may consider enabling nh and using `nh os switch` instead
  # which is actually a really good alternative to using this
  system =
    ldTernary pkgs
      {
        disableInstallerTools = config.programs.nh.enable;

        tools = {
          nixos-version.enable = true;
        };
      }
      {
        tools = {
          enable = false;
          darwin-version.enable = true;
        };
      };
}
