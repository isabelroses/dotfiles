{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      formatter = pkgs.treefmt.withConfig {
        runtimeInputs = with pkgs; [
          # keep-sorted start
          actionlint
          deadnix
          keep-sorted
          nixfmt
          shellcheck
          shfmt
          statix
          stylua
          taplo
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

          excludes = [
            ".git-crypt/*"
            "secrets/*"
          ];

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
            # keep-sorted end
          };
        };
      };
    };
}
