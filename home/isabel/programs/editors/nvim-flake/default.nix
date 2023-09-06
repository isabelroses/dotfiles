{
  inputs,
  pkgs,
  ...
}: let
  regexplainer = pkgs.fetchFromGitHub {
    owner = "bennypowers";
    repo = "nvim-regexplainer";
    rev = "4250c8f3c1307876384e70eeedde5149249e154f";
    hash = "sha256-15DLbKtOgUPq4DcF71jFYu31faDn52k3P1x47GL3+b0=";
  };
in {
  imports = [
    inputs.neovim-flake.homeManagerModules.default
  ];

  # https://notashelf.github.io/neovim-flake/
  programs.neovim-flake = {
    enable = true;
    settings.vim = {
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      enableEditorconfig = true;
      preventJunkFiles = true;
      enableLuaLoader = true;

      treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        lua
        markdown
        markdown-inline
      ];

      extraPlugins = with pkgs.vimPlugins; {
        aerial = {
          package = aerial-nvim;
          setup = "require('aerial').setup {}";
        };

        harpoon = {
          package = harpoon;
          setup = "require('harpoon').setup {}";
          after = ["aerial"];
        };

        nvim-surround = {
          package = nvim-surround;
          setup = "require('nvim-surround').setup{}";
        };

        regexplainer = {
          package = regexplainer;
        };
      };

      debugMode = {
        enable = false;
        logFile = "/tmp/nvim.log";
      };

      lsp = {
        formatOnSave = true;
        lspkind.enable = true;
        lsplines.enable = true;
        lightbulb.enable = true;
        lspsaga.enable = false;
        lspSignature.enable = true;
        nvimCodeActionMenu.enable = true;
        trouble.enable = false;
      };

      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
      };

      languages = {
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix.enable = true;
        html.enable = true;
        sql.enable = false;
        ts.enable = true;
        go.enable = false;
        python.enable = false;
        zig.enable = false;
        dart.enable = false;
        elixir.enable = false;
        svelte.enable = false;

        rust = {
          enable = true;
          crates.enable = true;
        };

        clang = {
          enable = false;
          lsp = {
            enable = true;
            server = "clangd";
          };
        };
      };

      visuals = {
        enable = true;
        nvimWebDevicons.enable = true;
        scrollBar.enable = false;
        smoothScroll.enable = false;
        cellularAutomaton.enable = false;
        fidget-nvim.enable = true;

        indentBlankline = {
          enable = true;
          fillChar = null;
          eolChar = null;
          showCurrContext = true;
        };

        cursorline = {
          enable = true;
          lineTimeout = 0;
        };
      };

      statusline = {
        lualine = {
          enable = true;
          theme = "catppuccin";
        };
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = true;
      };
      autopairs.enable = true;

      autocomplete = {
        enable = true;
        type = "nvim-cmp";
      };

      filetree = {
        nvimTree = {
          enable = true;
          openOnSetup = true;
          disableNetrw = true;

          hijackUnnamedBufferWhenOpening = true;
          hijackCursor = true;
          hijackDirectories = {
            enable = true;
            autoOpen = true;
          };

          git = {
            enable = true;
            showOnDirs = false;
            timeout = 100;
          };

          view = {
            preserveWindowProportions = false;
            cursorline = false;
            width = {
              min = 35;
              max = -1;
              padding = 1;
            };
          };

          renderer = {
            indentMarkers.enable = true;
            rootFolderLabel = false;

            icons = {
              modifiedPlacement = "after";
              gitPlacement = "after";
              show.git = true;
              show.modified = true;
            };
          };

          diagnostics.enable = true;

          modified = {
            enable = true;
            showOnDirs = false;
            showOnOpenDirs = true;
          };

          mappings = {
            toggle = "<C-w>";
          };
        };
      };

      tabline = {
        nvimBufferline.enable = true;
      };

      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = false;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions = false;
      };

      minimap = {
        # cool for vanity but practically useless on small screens
        minimap-vim.enable = false;
        codewindow.enable = false;
      };

      dashboard = {
        dashboard-nvim.enable = false;
        alpha.enable = true;
      };

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim = {
          enable = true;
          manualMode = false;
          detectionMethods = ["lsp" "pattern"];
          patterns = [
            ".git"
            ".hg"
            "Makefile"
            "package.json"
            "index.*"
            ".anchor"
          ];
        };
      };

      utility = {
        ccc.enable = true;
        icon-picker.enable = true;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = false;
        };
      };

      notes = {
        mind-nvim.enable = true;
        todo-comments.enable = true;
        obsidian.enable = false;
      };

      terminal = {
        toggleterm = {
          mappings.open = "<C-t>";
          enable = true;
          direction = "tab";
          lazygit = {
            enable = true;
            direction = "tab";
          };
        };
      };

      ui = {
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false;
        illuminate.enable = true;

        breadcrumbs = {
          enable = true;
          source = "nvim-navic";
          navbuddy.enable = false;
        };

        smartcolumn = {
          enable = true;
          columnAt.languages = {
            markdown = 80;
            nix = 150;
            ruby = 110;
            java = 120;
            go = [130];
          };
        };

        borders = {
          enable = true;
          globalStyle = "rounded";
        };
      };

      assistant = {
        copilot = {
          enable = true;
          cmp.enable = true;
        };
      };

      session = {
        nvim-session-manager = {
          enable = false;
          autoloadMode = "Disabled"; # misbehaves with dashboard
        };
      };

      gestures = {
        gesture-nvim.enable = false;
      };

      comments = {
        comment-nvim.enable = true;
      };

      presence = {
        presence-nvim.enable = true;
      };

      maps.normal = {
        "<leader>qq" = {
          action = "<cmd>qall!<CR>";
          silent = false;
          desc = "Quit all";
        };
        "<C-s>" = {
          action = ":w<CR>";
          silent = true;
          desc = "Save";
        };
      };
    };
  };
}
