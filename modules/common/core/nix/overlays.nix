{
  config,
  inputs,
  inputs',
  lib,
  ...
}: let
  nurOpt = config.modules.usrEnv.programs.nur;
in {
  nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
      
      (
        _: prev: {
          # temp fix until https://github.com/NixOS/nixpkgs/pull/249382 is merged
          gtklock = prev.gtklock.overrideAttrs (_: super: {
            nativeBuildInputs = super.nativeBuildInputs ++ [prev.wrapGAppsHook];
            buildInputs = super.buildInputs ++ [prev.librsvg];
          });
        }
      )
    ]
    ++ lib.optionals (nurOpt.enable) [
      (final: prev: {
        nur = import inputs.nur {
          nurpkgs = prev;
          pkgs = prev;
          repoOverrides =
            {}
            // lib.optionalAttrs (nurOpt.bella) {bella = inputs'.bella-nur.packages;}
            // lib.optionalAttrs (nurOpt.nekowinston) {nekowinston = inputs'.nekowinston-nur.packages;};
        };
      })
    ];
}
