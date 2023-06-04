{
  config,
  pkgs,
  ...
}: {
    config.home.sessionVariables = {
        ALTERNATE_EDITOR = "";
        EDITOR = "nvim";
        GIT_EDITOR = "nvim";
        VISUAL = "code";
        TERMINAL = "alacritty";

        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "gtk3";
        GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";

        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        HISTFILE = "${config.xdg.dataHome}/history";
        GNUPGHOME = "${config.xdg.dataHome}/gnupg";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    };
}