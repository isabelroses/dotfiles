{ pkgs, self, ... }:
let
  inherit (self.lib.hardware) ldTernary;
in
{
  system =
    ldTernary pkgs
      {
        disableInstallerTools = true;

        rebuild.enableNg = true;

        tools = {
          nixos-version.enable = true;
          nixos-rebuild.enable = true;
        };
      }
      {
        tools = {
          enable = false;
          darwin-version.enable = true;
          darwin-rebuild.enable = true;
        };
      };
}
