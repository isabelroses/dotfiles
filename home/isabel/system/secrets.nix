{ self, config, ... }:
let
  inherit (self.lib) mkUserSecret;

  inherit (config.xdg) configHome;
in
{
  age.secrets = {
    wakatime = mkUserSecret {
      file = "isabel/wakatime";
      path = configHome + "/wakatime/.wakatime.cfg";
    };

    nix-auth-tokens = mkUserSecret {
      file = "isabel/nix-auth-tokens";
    };
  };
}
