{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.meta) getExe;
in
{
  programs.fzf = {
    inherit (config.garden.profiles.workstation) enable;

    # don't take ctrl-r
    historyWidget.command = "";

    defaultCommand = "${getExe pkgs.fd} --type=f --hidden --exclude=.git";
    defaultOptions = [
      "--height=30%"
      "--layout=reverse"
      "--info=inline"
    ];
  };
}
