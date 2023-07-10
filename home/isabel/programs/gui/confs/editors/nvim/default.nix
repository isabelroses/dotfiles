{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
with lib; let
  cfg = osConfig.modules.programs.default;
in {
  config = mkIf (cfg.editor == "nvim") {
    home.file."${config.xdg.configHome}/nvim" = {
      source = inputs.isabel-nvim;
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      vimAlias = true;
      viAlias = false;
      vimdiffAlias = false;
      withRuby = false;
      withNodeJs = false;
      withPython3 = false;
      extraPackages = with pkgs; [
        texlab # latex LSP
        nil # nix language server
        alejandra # nix formatter
      ];
      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (plugins:
          with plugins; [
            tree-sitter-python
            tree-sitter-c
            tree-sitter-nix
            tree-sitter-cpp
            tree-sitter-rust
            tree-sitter-toml
            tree-sitter-json
            tree-sitter-lua
            tree-sitter-go
            tree-sitter-java
            tree-sitter-typescript
            tree-sitter-javascript
            tree-sitter-cmake
            tree-sitter-comment
            tree-sitter-http
            tree-sitter-regex
            tree-sitter-dart
            tree-sitter-make
            tree-sitter-html
            tree-sitter-css
            tree-sitter-latex
            tree-sitter-bibtex
            tree-sitter-php
            tree-sitter-sql
            tree-sitter-zig
            tree-sitter-dockerfile
            tree-sitter-markdown
          ]))
      ];
    };
  };
}
