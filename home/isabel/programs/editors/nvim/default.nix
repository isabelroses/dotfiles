{
  pkgs,
  lib,
  config,
  inputs,
  defaults,
  ...
}: {
  config = lib.mkIf (defaults.editor == "nvim") {
    xdg.configFile = let
      symlink = fileName: {recursive ? false}: {
        source = config.lib.file.mkOutOfStoreSymlink "${fileName}";
        inherit recursive;
      };
    in {
      "nvim" = symlink inputs.isabel-nvim {recursive = true;};
    };

    programs.neovim = {
      enable = true;
      package = pkgs.symlinkJoin {
        name = "neovim";
        paths = [pkgs.neovim-unwrapped];
        buildInputs = [pkgs.makeWrapper pkgs.gcc];
        postBuild = "wrapProgram $out/bin/nvim --prefix CC : ${pkgs.lib.getExe pkgs.gcc}";
      };
      vimAlias = true;
      viAlias = false;
      vimdiffAlias = false;
      withRuby = false;
      withNodeJs = false;
      withPython3 = false;
      extraPackages = with pkgs; [
        # external deps
        fd
        ripgrep
        lazygit

        texlab # latex LSP
        nil # nix language server
        alejandra # nix formatter
        shellcheck

        #rust
        cargo
        rust-analyzer
        rustc
        rustfmt

        # web dev
        nodePackages.alex

        # python
        nodePackages.pyright

        # lua
        stylua
        lua-language-server
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
