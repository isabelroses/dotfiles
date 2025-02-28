{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;
in
{
  programs.eza = mkIf (isModernShell config) {
    enable = true;
    icons = "auto";

    enableNushellIntegration = false;

    extraOptions = [
      "--group"
      "--group-directories-first"
      "--no-permissions"
      "--octal-permissions"
    ];
  };
}
