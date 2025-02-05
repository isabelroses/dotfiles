{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = config.garden.programs.firefox;
in
{
  imports = [
    ./extensions.nix
  ];

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      inherit (cfg) package;

      profiles.default = {
        isDefault = true;
      };
    };
  };
}
