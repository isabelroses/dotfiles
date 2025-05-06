{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe;
in
{
  programs.fzf = {
    inherit (config.garden.profiles.workstation) enable;

    colors = {
      fg = "#cdd6f4";
      "fg+" = "#cdd6f4";
      hl = "#f38ba8";
      "hl+" = "#f38ba8";
      header = "#ff69b4";
      info = "#cba6f7";
      marker = "#f5e0dc";
      pointer = "#f5e0dc";
      prompt = "#cba6f7";
      spinner = "#f5e0dc";
    };

    defaultCommand = "${getExe pkgs.fd} --type=f --hidden --exclude=.git";
    defaultOptions = [
      "--height=30%"
      "--layout=reverse"
      "--info=inline"
    ];
  };
}
