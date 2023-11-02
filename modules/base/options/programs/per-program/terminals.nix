{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.programs.terminals = {
    alacritty.enable = mkEnableOption "Alacritty terminal emulator";
    kitty.enable = mkEnableOption "Kitty terminal emulator";
    # TODO: wezterm.enable = mkEnableOption "WezTerm terminal emulator";
  };
}
