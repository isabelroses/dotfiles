{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  config = {
    # pick our ports
    catppuccin.forgejo.enable = true;

    console.colors = lib.mkIf config.catppuccin.enable [
      "000000"
      "f38ba8"
      "a6e3a1"
      "f9e2af"
      "89b4fa"
      "f5c2e7"
      "94e2d5"
      "bac2de"
      "585b70"
      "f38ba8"
      "a6e3a1"
      "f9e2af"
      "89b4fa"
      "f5c2e7"
      "94e2d5"
      "a6adc8"
    ];
  };
}
