{ inputs, ... }:
{
  imports = [ inputs.evergarden.homeManagerModules.default ];

  config = {
    evergarden = {
      enable = true;
      variant = "fall";
      accent = "pink";
    };
  };
}
