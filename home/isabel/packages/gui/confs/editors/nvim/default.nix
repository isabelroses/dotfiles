{
  pkgs,
  lib,
  osConfig,
  ...
}:
with lib; let
  cfg = osConfig.modules.programs.default;
in {
  config = mkIf (cfg.editor == "nvim") {
    xdg.configFile."nvim".source = ./config;
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
        copilot-lua
        lsp_lines-nvim
        vim-nix
        nvim-ts-autotag
        cmp-nvim-lsp-signature-help
        cmp-buffer
        comment-nvim
        lsp_lines-nvim
        null-ls-nvim
        vim-fugitive
        friendly-snippets
        luasnip
        rust-tools-nvim
        crates-nvim
        vim-illuminate
        cmp_luasnip
        nvim-cmp
        impatient-nvim
        indent-blankline-nvim
        telescope-nvim
        nvim-web-devicons
        cmp-nvim-lsp
        cmp-path
        catppuccin-nvim
        lspkind-nvim
        nvim-lspconfig
        hop-nvim
        alpha-nvim
        nvim-autopairs
        nvim-colorizer-lua
        nvim-ts-rainbow
        gitsigns-nvim
        #neo-tree-nvim
        nvim-tree-lua
        toggleterm-nvim
        todo-comments-nvim
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
