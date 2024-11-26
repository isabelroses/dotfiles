{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.validators) isModernShell;
  inherit (lib.attrsets) mapAttrsToList;

  find = "${getExe pkgs.fd} --type=f --hidden --exclude=.git";
in
{
  programs.fzf = mkIf (isModernShell osConfig) {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableFishIntegration = config.programs.fish.enable;

    defaultCommand = find;
    defaultOptions = mapAttrsToList (n: v: "--${n}='${v}'") {
      margin = "0,2";
      padding = "1";
      height = "16";
      layout = "reverse-list";
      info = "right";
      preview-window = "border-rounded";
      prompt = "> ";
      marker = ">";
      pointer = "◆";
      separator = "─";
      scrollbar = "│";
    };

    fileWidgetCommand = find;
    fileWidgetOptions = [ "--preview 'head {}'" ];

    changeDirWidgetCommand = "${getExe pkgs.fd} --type=d --hidden --exclude=.git";

    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
  };
}
