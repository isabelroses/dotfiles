{
  lib,
  _class,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mergeAttrsList optionalAttrs;

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

  config = mergeAttrsList [
    (optionalAttrs (_class == "nixos") {
      system = {
        disableInstallerTools = cfg.minimal;

        rebuild.enableNg = true;

        tools = {
          nixos-version.enable = true;
          nixos-rebuild.enable = false;
        };
      };
    })

    (optionalAttrs (_class == "darwin") {
      system.tools = {
        enable = !cfg.minimal;

        darwin-version.enable = true;
        # needed for nh, and if you want to darwin-rebuild
        darwin-rebuild.enable = true;
      };
    })
  ];
}
