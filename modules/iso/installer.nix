# TODO: work on install script
{ pkgs, config, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "iznix-install";
      runtimeInputs = [ config.nix.package ];
      text = ''
        set -euxo pipefail

        nixos-install --flake "/root/flake#" "''${installArgs[@]}"
      '';
    })
  ];
}
