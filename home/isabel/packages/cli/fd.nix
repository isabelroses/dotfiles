{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  programs.fd = mkIf (isModernShell config) {
    enable = true;

    hidden = true;
    ignores = [
      ".git/"
      "*.bak"
    ];
  };
}
