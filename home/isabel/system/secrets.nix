{ self, config, ... }:
let
  inherit (self.lib) mkUserSecret;

  inherit (config.xdg) configHome;
in
{
  sops.secrets = {
    wakatime = mkUserSecret "isabel" {
      path = configHome + "/wakatime/.wakatime.cfg";
    };

    nix-auth-tokens = mkUserSecret "isabel" { };
  };
}
