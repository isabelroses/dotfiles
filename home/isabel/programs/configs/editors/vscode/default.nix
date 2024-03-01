{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) mkIf;

  mkLink = config.lib.file.mkOutOfStoreSymlink;

  vscodeStore = "${osConfig.modules.environment.flakePath}/home/${osConfig.modules.system.mainUser}/programs/configs/editors/vscode";
  keybindingsFile = mkLink "${vscodeStore}/keybindings.json";
  settingsFile = mkLink "${vscodeStore}/settings.json";
in {
  config = mkIf osConfig.modules.programs.agnostic.editors.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        # THEMEING
        catppuccin.catppuccin-vsc-icons
        (pkgs.catppuccin-vsc.override {
          accent = "pink";
          boldKeywords = true;
          italicComments = true;
          italicKeywords = true;
          extraBordersEnabled = false;
          workbenchMode = "flat";
          bracketMode = "rainbow";
          colorOverrides = {};
          customUIColors = {};
        })

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

    xdg.configFile = mkIf isLinux {
      "VSCode/User/keybindings.json".source = keybindingsFile;
      "VSCode/User/settings.json".source = settingsFile;
    };

    home.file = mkIf isDarwin {
      "Library/Application Support/Code/User/keybindings.json".source = keybindingsFile;
      "Library/Application Support/Code/User/settings.json".source = settingsFile;
    };
  };
}
