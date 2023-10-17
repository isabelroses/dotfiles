{
  config,
  lib,
  inputs',
  ...
}:
with lib; let
  cfg = config.programs.steam;
in {
  options.programs.steam = {
    withProtonGE = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether or not proton-ge from nix-gaming should be appended to `extraCompatPackages`.
      '';
    };

    extraCompatPackages = mkOption {
      type = with types; listOf package;
      default = [];
      defaultText = literalExpression "[]";
      example = literalExpression ''
        with pkgs; [
          luxtorpeda
          proton-ge
        ]
      '';
      description = mdDoc ''
        Extra packages to be used as compatibility tools for Steam on Linux. Packages will be included
        in the `STEAM_EXTRA_COMPAT_TOOLS_PATHS` environmental variable. For more information see
        <https://github.com/ValveSoftware/steam-for-linux/issues/6310">.
      '';
    };
  };

  config = let
    CompatPackages =
      if cfg.withProtonGE == true
      then cfg.extraCompatPackages ++ [inputs'.nix-gaming.packages.proton-ge]
      else cfg.extraCompatPackages;
  in
    mkIf cfg.enable {
      # Steam hardware (just in case)
      hardware.steam-hardware.enable = true;

      # Append the extra compatibility packages to whatever else the env variable was populated with.
      # For more information see https://github.com/ValveSoftware/steam-for-linux/issues/6310.
      environment.sessionVariables = mkIf (CompatPackages != []) {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = [
          (makeBinPath CompatPackages)
        ];
      };
    };
}
