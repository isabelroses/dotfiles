{lib, ...}:
with lib; {
  options.modules.usrEnv = {
    desktop = mkOption {
      type = types.enum ["Hyprland"];
      default = "Hyprland";
      description = lib.mdDoc ''
        The desktop environment to be used.
      '';
    };

    isWayland = mkOption {
      type = types.bool;
      default = true;
      description = lib.mdDoc ''
        Whether to enable Wayland compatibility module. This generally includes:
          - Wayland nixpkgs overlay
          - Wayland only services
          - Wayland only programs
          - Wayland compositors
          - Wayland compatible versions of packages
      '';
    };

    useHomeManager = mkOption {
      type = types.bool;
      default = true;
      description = lib.mdDoc ''
        Whether to use home-manager or not. Username MUST be set if this option is enabled.
      '';
    };

    noiseSupressor = mkOption {
      type = with types; nullOr (enum ["rnnoise" "noisetorch"]);
      default = "rnnoise";
      description = lib.mdDoc ''
        The noise supressor to be used for desktop systems with sound enabled.
      '';
    };
  };
}
