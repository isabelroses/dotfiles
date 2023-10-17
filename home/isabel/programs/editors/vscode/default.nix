{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig.modules) device programs;
  sys = osConfig.modules.system;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable) {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        bradlc.vscode-tailwindcss
        catppuccin.catppuccin-vsc-icons
        catppuccin.catppuccin-vsc
        eamodio.gitlens
        github.copilot
        github.vscode-pull-request-github
        jnoortheen.nix-ide
        kamadorueda.alejandra
        rust-lang.rust-analyzer
        devsense.phptools-vscode
        shd101wyy.markdown-preview-enhanced
        ms-vscode-remote.remote-ssh
        ms-vscode.live-server
      ];
      mutableExtensionsDir = true;
    };
  };
}
