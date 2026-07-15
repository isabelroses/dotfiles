{
  lib,
  writeShellScriptBin,
  treefmt,

  # keep-sorted start
  actionlint,
  deadnix,
  keep-sorted,
  locker,
  nixfmt,
  shellcheck,
  shfmt,
  statix,
  stylua,
  taplo,
  typos,
  yamlfmt,
  zizmor,
  # keep-sorted end
}:
treefmt.withConfig {
  runtimeInputs = [
    # keep-sorted start
    actionlint
    deadnix
    keep-sorted
    locker
    nixfmt
    shellcheck
    shfmt
    statix
    stylua
    taplo
    typos
    yamlfmt
    zizmor
    # keep-sorted end

    (writeShellScriptBin "statix-fix" ''
      for file in "$@"; do
        ${lib.getExe statix} fix "$file"
      done
    '')
  ];

  settings = {
    on-unmatched = "info";
    tree-root-file = "flake.nix";

    excludes = [ "secrets/*" ];

    formatter = {
      # keep-sorted start block=yes newline_separated=yes
      actionlint = {
        command = "actionlint";
        includes = [
          ".github/workflows/*.yml"
          ".github/workflows/*.yaml"
        ];
      };

      deadnix = {
        command = "deadnix";
        options = [ "--edit" ];
        includes = [ "*.nix" ];
      };

      keep-sorted = {
        command = "keep-sorted";
        includes = [ "*" ];
      };

      locker = {
        command = "locker";
        includes = [ "flake.lock" ];
      };

      nixfmt = {
        command = "nixfmt";
        includes = [ "*.nix" ];
      };

      shellcheck = {
        command = "shellcheck";
        includes = [
          "*.sh"
          "*.bash"
          # direnv
          "*.envrc"
          "*.envrc.*"
        ];
      };

      shfmt = {
        command = "shfmt";
        options = [
          "-s"
          "-w"
          "-i"
          "2"
        ];
        includes = [
          "*.sh"
          "*.bash"
          # direnv
          "*.envrc"
          "*.envrc.*"
        ];
      };

      statix = {
        command = "statix-fix";
        includes = [ "*.nix" ];
      };

      stylua = {
        command = "stylua";
        includes = [ "*.lua" ];
      };

      taplo = {
        command = "taplo";
        options = "format";
        includes = [ "*.toml" ];
      };

      typos = {
        command = "typos";
        options = [ "--fix" ];
        includes = [
          "*.nix"
          "*.md"
        ];
        excludes = [
          # weird option names
          "home/isabel/discord.nix"
          # colors
          "modules/nixos/catppuccin.nix"
          # driver name
          "modules/nixos/hardware/gpu/nvidia.nix"
        ];
      };

      yamlfmt = {
        command = "yamlfmt";
        options = [
          "-formatter"
          "retain_line_breaks_single=true"
        ];
        includes = [
          "*.yml"
          "*.yaml"
        ];
      };

      zizmor = {
        command = "zizmor";
        includes = [
          ".github/workflows/*.yml"
          ".github/workflows/*.yaml"
        ];
      };
      # keep-sorted end
    };
  };
}
