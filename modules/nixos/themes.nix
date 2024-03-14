{inputs, ...}: {
  imports = [inputs.catppuccin.nixosModules.catppuccin];

  config.catppuccin.flavour = "mocha";
}
