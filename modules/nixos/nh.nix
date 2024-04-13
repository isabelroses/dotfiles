{inputs, ...}: {
  imports = [inputs.nh.nixosModules.default];

  config.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "daily";
    };
  };
}
