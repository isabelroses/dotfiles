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
  programs.fd = mkIf (isModernShell config) {
    enable = true;

    hidden = true;
    ignores = [
      ".git/"
      "*.bak"
    ];
  };
}
