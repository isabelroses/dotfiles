{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  mkExt =
    name:
    config.lib.vicinae.mkExtension {
      inherit name;
      src =
        pkgs.fetchFromGitHub {
          owner = "vicinaehq";
          repo = "extensions";
          rev = "ec7334e9bb636f4771580238bd3569b58dbce879";
          hash = "sha256-C2b6upygLE6xUP/cTSKZfVjMXOXOOqpP5Xmgb9r2dhA=";
        }
        + "/extensions/${name}";
    };
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;

      settings = {
        window.opacity = 1;
      };

      extensions = map mkExt [
        "nix"
        "wifi-commander"
        "bluetooth"
        "mullvad"
      ];
    };
  };
}
