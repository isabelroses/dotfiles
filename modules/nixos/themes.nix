{inputs, ...}: {
  imports = [inputs.catppuccin.nixosModules.default];

  config.catppuccin = {
    flavor = "mocha";
  };
}
