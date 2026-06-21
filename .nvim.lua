local flake_expr = "builtins.getFlake (toString ./.)"

vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = string.format("import (%s).inputs.nixpkgs { }", flake_expr),
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = string.format("(%s).nixosConfigurations.amaterasu.options", flake_expr),
        },
        ["nix-darwin"] = {
          expr = string.format("(%s).darwinConfigurations.tatsumaki.options", flake_expr),
        },
        ["home-manager"] = {
          expr = string.format(
            "(%s).nixosConfigurations.amaterasu.options.home-manager.users.type.getSubOptions []",
            flake_expr
          ),
        },
      },
    },
  },
})
