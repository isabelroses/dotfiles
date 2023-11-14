{
  lib,
  pkgs,
  osConfig,
  config,
  ...
}: let
  acceptedTypes = ["laptop" "desktop" "hybrid"];
  inherit (osConfig.modules.system) flakePath mainUser;
in {
  programs.vscode = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.editors.vscode.enable) {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      # THEMEING
      catppuccin.catppuccin-vsc-icons
      catppuccin.catppuccin-vsc

      # GIT
      github.copilot
      github.copilot-chat
      github.vscode-pull-request-github
      github.vscode-github-actions
      eamodio.gitlens

      # UTILITIES
      ms-vscode-remote.remote-ssh
      ms-vscode.live-server
      vscodevim.vim #yes i hate myself
      wakatime.vscode-wakatime

      # LANGUAGES BASED EXTENSIONS
      ## NIX
      jnoortheen.nix-ide
      kamadorueda.alejandra
      mkhl.direnv

      ## RUST
      serayuzgur.crates
      rust-lang.rust-analyzer

      ## GO
      golang.go

      ## LUA
      sumneko.lua

      ## TOML
      tamasfe.even-better-toml

      ## WEB DEV
      ### GENERAL
      bradlc.vscode-tailwindcss
      dbaeumer.vscode-eslint
      denoland.vscode-deno

      ### PHP
      devsense.phptools-vscode

      ### MARKDOWN
      shd101wyy.markdown-preview-enhanced
      unifiedjs.vscode-mdx
      valentjn.vscode-ltex
    ];
    mutableExtensionsDir = true;
  };

  xdg.configFile = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.gui.enable) {
    "VSCodium/User/keybindings.json".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/home/${mainUser}/programs/configs/editors/vscode/keybindings.json";
    "VSCodium/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/home/${mainUser}/programs/configs/editors/vscode/settings.json";
  };
}
