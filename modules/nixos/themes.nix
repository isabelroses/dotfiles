{inputs, ...}: {
  imports = [inputs.catppuccin.nixosModules.catppuccin];

  config.catppuccin = {
    enable = true;
    flavour = "mocha";
  };
}
