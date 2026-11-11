{
  lib,
  pkgs,
  _class,
  config,
  ...
}:
let
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.system.tools;
in
{
  options.garden.system.tools = {
    enable = mkEnableOption "tools" // {
      default = true;
    };

    minimal = mkEnableOption "limit to minimal system tooling" // {
      default = true;
    };
  };

  config =
    if _class == "nixos" then
      {
        system = {
          disableInstallerTools = cfg.minimal;

          tools = {
            nixos-version.enable = true;
            nixos-rebuild = {
              enable = true;
              enableRun0Elevation = true;
            };
          };

          # lix 2.97 drops `ssh://` stores and `nix copy` to `ssh-ng://` checks
          # signatures, which our unsigned builds lack. this passes
          # `--no-check-sigs` for ssh-ng copies like nix-copy-closure did.
          # drop once <https://github.com/NixOS/nixpkgs/pull/574160> is merged
          build.nixos-rebuild = lib.mkForce (
            (pkgs.nixos-rebuild-ng.override { nix = config.nix.package; }).overrideAttrs (oa: {
              patches = (oa.patches or [ ]) ++ [
                (pkgs.fetchpatch {
                  name = "nixos-rebuild-ng-ssh-ng-no-check-sigs.patch";
                  url = "https://github.com/NixOS/nixpkgs/commit/e2cad8b9ce401587a9661a4573976d14a7043904.patch";
                  relative = "pkgs/by-name/ni/nixos-rebuild-ng/src";
                  hash = "sha256-JXiP3MqwwL1gyOPs0BefNhWycmg6bukk1sro7XOGgMk=";
                })
              ];
            })
          );
        };
      }
    else
      {
        system.tools = {
          enable = !cfg.minimal;

          darwin-version.enable = true;
          darwin-rebuild.enable = true;
        };
      };
}
