{
  lib,
  osConfig,
  defaults,
  ...
}: let
  inherit (osConfig.modules.system) video;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.gui.enable && video.enable && defaults.terminal == "kitty") {
    programs.kitty = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        background_opacity = "0.85";
        font_family = "RobotoMono Nerd Font";
        font_size = 13;
        disable_ligatures = "never";
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";
        cursor_stop_blinking_after = "15.0";
        scrollback_lines = 10000;
        click_interval = "0.5";
        select_by_word_characters = ":@-./_~?&=%+#";
        remember_window_size = false;
        allow_remote_control = true;
        initial_window_width = 640;
        initial_window_height = 400;
        repaint_delay = 15;
        input_delay = 3;
        visual_bell_duration = "0.0";
        url_style = "double";
        open_url_with = "default";
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        window_padding_width = 2;
        window_margin_width = 2;
      };
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
