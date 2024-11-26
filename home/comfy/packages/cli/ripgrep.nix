{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  programs.ripgrep = mkIf (isModernShell osConfig) {
    enable = true;

    # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!.git/*"
      "--smart-case"
    ];
  };
}
