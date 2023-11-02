{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.programs.editors = {
    neovim.enable = mkEnableOption "Neovim editor";
    vscode.enable = mkEnableOption "VScode editor";
    micro.enable = mkEnableOption "Micro editor";
  };
}
