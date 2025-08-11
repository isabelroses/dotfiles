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
    defaultOptions = (mapAttrsToList (n: v: "--${n}='${v}'") {
      margin = "0";
      padding = "0";
      height = "14";
      layout = "reverse-list";
      info = "inline-right";
      preview-window = "border-rounded";
      prompt = " ";
      pointer = "";
      marker = "│";
      separator = "─";
      scrollbar = "│";
    }) ++ [ "--no-separator" ];

    fileWidgetCommand = find;
    fileWidgetOptions = [ "--preview 'head {}'" ];

    changeDirWidgetCommand = "${getExe pkgs.fd} --type=d --hidden --exclude=.git";

    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
  };
}
