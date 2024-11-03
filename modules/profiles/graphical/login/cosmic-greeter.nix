{ config, ... }:
let
  inherit (config.garden) environment;
in
{
  services.displayManager.cosmic-greeter.enable = environment.loginManager == "cosmic-greeter";
}
