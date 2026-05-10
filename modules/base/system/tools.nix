{
  lib,
  _class,
  config,
  ...
}:
let
  inherit (lib.options) mkEnableOption;

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

  config =
    if _class == "nixos" then
      {
        system = {
          disableInstallerTools = cfg.minimal;

          tools = {
            nixos-version.enable = true;
            nixos-rebuild.enable = true;
          };
        };
      }
    else
      {
        system.tools = {
          enable = !cfg.minimal;

          darwin-version.enable = true;
          darwin-rebuild.enable = true;
        };
      };
}
