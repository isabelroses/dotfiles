local repo_expr = "import ./default.nix { }"

vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "npins", ".git" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = string.format("(%s).input.pkgs", repo_expr),
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = string.format("(%s).hosts.amaterasu.options", repo_expr),
        },
        ["nix-darwin"] = {
          expr = string.format("(%s).hosts.tatsumaki.options", repo_expr),
        },
        ["home-manager"] = {
          expr = string.format("(%s).hosts.amaterasu.options.home-manager.users.type.getSubOptions []", repo_expr),
        },
      },
    },
  },
})
