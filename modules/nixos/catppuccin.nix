{
  lib,
  self,
  config,
  inputs,
  ...
}:
let
  p = self.lib.palette;
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  config = {
    # pick our ports
    catppuccin.forgejo.enable = true;

    console.colors = lib.modules.mkIf config.catppuccin.enable (
      map (lib.strings.removePrefix "#") [
        p.base
        p.red
        p.green
        p.yellow
        p.blue
        p.pink
        p.teal
        p.text
        p.textSubtle
        p.red
        p.green
        p.yellow
        p.blue
        p.pink
        p.teal
        p.textMuted
      ]
    );
  };
}
