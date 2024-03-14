{inputs, ...}: {
  imports = [inputs.catppuccin.nixosModules.catppuccin];

  config.catppuccin = {
    flavor = "mocha";
  };
}
