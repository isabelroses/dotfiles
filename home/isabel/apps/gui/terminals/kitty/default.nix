{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    programs.kitty = {
      enable = true;
      settings = import ./settings.nix;
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+alt+c" = "copy_to_clipboard";
        "ctrl+alt+v" = "paste_from_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";

        "ctrl+shift+up" = "increase_font_size";
        "ctrl+shift+down" = "decrease_font_size";
        "ctrl+shift+backspace" = "restore_font_size";

        "ctrl+shift+enter" = "new_window";
        "ctrl+shift+n" = "new_os_window";
        "ctrl+shift+w" = "close_window";
        "ctrl+shift+]" = "next_window";
        "ctrl+shift+[" = "previous_window";
        "ctrl+shift+f" = "move_window_forward";
        "ctrl+shift+b" = "move_window_backward";
        "ctrl+shift+`" = "move_window_to_top";
        "ctrl+shift+1" = "first_window";
        "ctrl+shift+2" = "second_window";
        "ctrl+shift+3" = "third_window";
        "ctrl+shift+4" = "fourth_window";
        "ctrl+shift+5" = "fifth_window";
        "ctrl+shift+6" = "sixth_window";
        "ctrl+shift+7" = "seventh_window";
        "ctrl+shift+8" = "eighth_window";
        "ctrl+shift+9" = "ninth_window";
        "ctrl+shift+0" = "tenth_window";

        "ctrl+shift+right" = "next_tab";
        "ctrl+shift+left" = "previous_tab";
        "ctrl+shift+t" = "new_tab";
        "ctrl+shift+q" = "close_tab";
        "ctrl+shift+l" = "next_layout";
        "ctrl+shift+." = "move_tab_forward";
        "ctrl+shift+," = "move_tab_backward";
        "ctrl+shift+alt+t" = "set_tab_title";
      };
    };
  };
}
