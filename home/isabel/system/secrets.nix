{ config, ... }:
let
  inherit (config.xdg) configHome;
in
{
  sops.secrets = {
    wakatime = {
      path = configHome + "/wakatime/.wakatime.cfg";
    };

    nix-auth-tokens = { };
  };
}
