{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.options) mkEnableOption;

  inherit (self.lib.hardware) ldTernary;

  cfg = config.garden.system.tools;
in
{
  options.garden.system.tools = {
    enable = mkEnableOption "tools" // {
      default = true;
    };

    minimal = mkEnableOption "limit to minimal system tooling" // {
      default = true;
    };
  };

  config.system =
    ldTernary pkgs
      {
        disableInstallerTools = cfg.minimal;

        rebuild.enableNg = true;

        tools = {
          nixos-version.enable = true;
          nixos-rebuild.enable = true;
        };
      }
      {
        tools = {
          enable = !cfg.minimal;

          darwin-version.enable = true;
          darwin-rebuild.enable = true;
        };
      };
}
