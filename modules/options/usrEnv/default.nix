{lib, ...}: let
  inherit (lib) mkOption types mdDoc;
in {
  imports = [
    ./programs
    ./services
  ];
  options.modules.usrEnv = {
    useHomeManager = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Whether to use home-manager or not. Username MUST be set if this option is enabled.
      '';
    };

    desktop = mkOption {
      type = types.enum ["Hyprland"];
      default = "Hyprland";
      description = mdDoc ''
        The desktop environment to be used.
      '';
    };

    isWayland = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc ''
        Whether to enable Wayland compatibility module. This generally includes:
          - Wayland nixpkgs overlay
          - Wayland only services
          - Wayland only programs
          - Wayland compositors
          - Wayland compatible versions of packages
      '';
    };
  };
}
