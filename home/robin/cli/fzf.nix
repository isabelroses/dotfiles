{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe mapAttrsToList;

  find = "${getExe pkgs.fd} --type=f --hidden --exclude=.git";
in
{
  programs.fzf = {
    inherit (config.garden.profiles.workstation) enable;

    defaultCommand = find;
    defaultOptions = mapAttrsToList (n: v: "--${n}='${v}'") {
      margin = "0";
      padding = "0";
      height = "14";
      layout = "reverse-list";
      info = "right";
      preview-window = "border-rounded";
      prompt = " ";
      pointer = "";
      marker = "│";
      separator = "─";
      scrollbar = "│";
    };

    fileWidgetCommand = find;
    fileWidgetOptions = [ "--preview 'head {}'" ];

    changeDirWidgetCommand = "${getExe pkgs.fd} --type=d --hidden --exclude=.git";

    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];

    colors = {
      fg = "15"; # Text
      bg = "-1"; # Background
      "fg+" = "15"; # Text (current line)
      "bg+" = "8"; # Background (current line)
      preview-fg = "-1"; # Preview window text
      preview-bg = "-1"; # Preview window background
      hl = "9"; # Highlighted substrings
      "hl+" = "9"; # Highlighted substrings (current line)
      gutter = "-1"; # Gutter on the left (defaults to bg+)
      info = "4"; # Info
      border = "-1"; # Border of the preview window and horizontal separators (--border)
      prompt = "5"; # Prompt
      pointer = "15"; # Pointer to the current line
      marker = "3"; # Multi-select marker
      spinner = "15"; # Streaming input indicator
      header = "15"; # Header
    };
  };
}
