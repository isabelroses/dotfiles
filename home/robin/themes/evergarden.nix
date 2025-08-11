{ inputs, ... }:
{
  imports = [ inputs.evergarden.homeManagerModules.default ];

  config = {
    evergarden = {
      enable = true;
      variant = "winter";
      accent = "pink";
    };
  };
}
