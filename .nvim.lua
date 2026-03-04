local lspconfig = require("lspconfig")

local hostname = vim.loop.os_gethostname()

lspconfig.nixd.setup({
  cmd = { "nixd" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.' .. hostname .. ".options",
        },
        ["nix-darwin"] = {
          expr = '(builtins.getFlake ("git+file://" + toString ./.)).darwinConfigurations.' .. hostname .. ".options",
        },
        ["home-manager"] = {
          expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations."
            .. hostname
            .. ".options.home-manager.users.type.getSubOptions []",
        },
        ["flake-parts"] = {
          expr = "(builtins.getFlake (builtins.toString ./.)).debug.options",
        },
        ["flake-parts2"] = {
          expr = "(builtins.getFlake (builtins.toString ./.)).currentSystem.options",
        },
      },
    },
  },
})
