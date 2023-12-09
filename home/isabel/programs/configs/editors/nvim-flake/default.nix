{
  osConfig,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.neovim-flake.homeManagerModules.default];

  # https://notashelf.github.io/neovim-flake/
  programs.neovim-flake = lib.mkIf osConfig.modules.programs.editors.neovim.enable {
    enable = true;
    settings.vim = {
      package = pkgs.symlinkJoin {
        name = "neovim";
        paths = [pkgs.neovim-unwrapped];
        # postBuild = "rm $out/share/applications/nvim.desktop";
      };

      viAlias = true;
      vimAlias = true;

      enableEditorconfig = true;
      preventJunkFiles = true;
      enableLuaLoader = true;
      useSystemClipboard = true;

      treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        regex
        markdown
        markdown-inline
      ];

      extraPlugins = let
        inherit (pkgs.vimPlugins) friendly-snippets aerial-nvim nvim-surround undotree harpoon;
      in {
        friendly-snippets = {package = friendly-snippets;};

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
          setup = "require('nvim-surround').setup {}";
        };

        undotree = {
          package = undotree;
          setup = ''
            vim.g.undotree_ShortIndicators = true
            vim.g.undotree_TreeVertShape = '│'
          '';
        };
      };

      spellChecking.enable = true;

      languages = {
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix.enable = true;
        html.enable = true;
        markdown.enable = true;
        sql.enable = false;
        ts.enable = true;
        go.enable = false;
        python.enable = false;
        zig.enable = false;
        dart.enable = false;
        elixir.enable = false;
        svelte.enable = false;
        php.enable = false;
        bash.enable = true;

        lua = {
          enable = true;
          lsp.neodev.enable = true;
        };

        rust = {
          enable = true;
          crates.enable = true;
        };

        clang = {
          enable = true;
          lsp = {
            enable = true;
            server = "clangd";
          };
        };
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
        nvim-docs-view.enable = true;
      };

      debugMode = {
        enable = false;
        logFile = "/tmp/nvim.log";
      };

      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
      };

      visuals = {
        enable = true;
        nvimWebDevicons.enable = true;
        scrollBar.enable = false;
        smoothScroll.enable = true;
        cellularAutomaton.enable = false;
        fidget-nvim.enable = true;

        indentBlankline = {
          enable = true;
          fillChar = null;
          eolChar = null;
          scope.enabled = true;
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

        mappings = {
          confirm = "<Tab>";
          next = "<Down>";
          previous = "<Up>";
        };
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
            width = 35;
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

          filters = {
            dotfiles = true;
            gitIgnored = true;
          };

          diagnostics.enable = true;

          modified = {
            enable = true;
            showOnDirs = false;
            showOnOpenDirs = true;
          };

          mappings = {
            toggle = "<leader>e";
            refresh = "<leader>er";
            findFile = "<leader>ef";
            focus = "<leader>et";
          };
        };
      };

      tabline = {
        nvimBufferline.enable = true;
      };

      treesitter = {
        fold = true;
        context.enable = true;
      };

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = false;
      };

      telescope = {
        enable = true;

        mappings = {
          findFiles = "<leader><leader>";
          liveGrep = "<leader>fs";
          treesitter = "<leader>ffs";

          gitCommits = "<leader>fgc";
          gitBufferCommits = "<leader>fgbc";
          gitBranches = "<leader>fgb";
          gitStatus = "<leader>fgs";
          gitStash = " <leader>fgx";
        };
      };

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions = false;
      };

      minimap = {
        minimap-vim.enable = false;
        codewindow.enable = false;
      };

      dashboard = {
        dashboard-nvim.enable = false;
        alpha.enable = false;
        startify.enable = false;
      };

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim = {
          enable = true;
          manualMode = false;
          detectionMethods = ["lsp" "pattern"];
        };
      };

      utility = {
        ccc.enable = false; # color picker
        icon-picker.enable = true;
        diffview-nvim.enable = true;
        surround.enable = true; # quick delimters altering

        vim-wakatime = {
          enable = true;
          cli-package = pkgs.wakatime;
        };

        motion = {
          hop.enable = true;
          leap.enable = false;
        };
      };

      notes = {
        todo-comments = {
          enable = true;

          mappings = {
            quickFix = "<leader>tdf";
            telescope = "<leader>tds";
          };
        };

        obsidian = {
          enable = false;
          dir = "~/documents/obsidian";
          completion.nvim_cmp = true;
        };
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
          enable = true;

          mappings = {
            deleteSession = "<leader>sd";
            loadLastSession = "<leader>slt";
            loadSession = "<leader>sl";
            saveCurrentSession = "<leader>ss";
          };
        };
      };

      gestures = {
        gesture-nvim.enable = false;
      };

      comments = {
        comment-nvim.enable = true;
      };

      presence = {
        presence-nvim.enable = false;
      };

      maps.normal = {
        "<leader>qq" = {
          action = "<cmd>qall!<CR>";
          silent = true;
          desc = "Quit all";
        };
        "<C-s>" = {
          action = ":w<CR>";
          silent = true;
          desc = "Save";
        };
        "<leader>es" = {
          action = ''
            function ()
              nvim-tree-api.tree.toggle_hidden_filter()
              nvim-tree-api.tree.toggle_gitignore_filter()
            end)
          '';
          silent = true;
          desc = "Show hidden files";
        };
      };
    };
  };
}
