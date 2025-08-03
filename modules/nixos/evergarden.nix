{
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.evergarden.nixosModules.evergarden
  ];

  config = {
    evergarden = {
      enable = lib.mkDefault (!config.catppuccin.enable);
      variant = "winter";
    };
  };
}
