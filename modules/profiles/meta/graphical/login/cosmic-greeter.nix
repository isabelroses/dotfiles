{ config, ... }:
let
  inherit (config.garden) environment;
in
{
  services.displayManager.cosmic-greeter.embale = environment.loginManager == "cosmic-greeter";
}
