{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  programs.fd = mkIf (isModernShell osConfig) {
    enable = true;

    hidden = true;
    ignores = [
      ".git/"
      "*.bak"
    ];
  };
}
