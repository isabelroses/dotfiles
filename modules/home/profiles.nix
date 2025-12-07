{
  lib,
  config,
  osClass,
  osConfig,
  ...
}:
let
  inherit (lib) mkEnableOption;
in
{
  options.garden.profiles.media = {
    creation.enable = mkEnableOption "media creation profile";
    streaming.enable = mkEnableOption "media streaming profile";

    watching.enable = mkEnableOption "media watching profile" // {
      default = config.garden.profiles.graphical.enable && osClass == "nixos";
    };
  };

  config = {
    garden.profiles = {
      inherit (osConfig.garden.profiles)
        graphical
        headless
        workstation
        laptop
        server
        ;
    };
  };
}
