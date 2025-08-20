{
  lib,
  pkgs,
  inputs,
  options,
  config,
  ...
}:
let
  cfg = config.programs.izvim;
in
{
  imports = [ inputs.izvim.homeModules.default ];

  programs.izvim = {
    inherit (config.garden.profiles.workstation) enable;
    includePerLanguageTooling = true;

    package = lib.mkForce (
      options.programs.izvim.package.default.override {
        inherit (cfg) includePerLanguageTooling;

        nil = (pkgs.nil.override { nix = config.nix.package; }).overrideAttrs (
          finalAttrs: oa: {
            src = pkgs.fetchFromGitHub {
              owner = "oxalica";
              repo = "nil";
              rev = "cd7a6f6d5dc58484e62a8e85677e06e47cf2bd4d";
              hash = "sha256-fK4INnIJQNAA8cyjcDRZSPleA+N/STI6I0oBDMZ2r+E=";
            };

            cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
              inherit (finalAttrs) src;
              hash = "sha256-wvtCLCvpxbUo7VZPExUI7J+U06jnWBMnVuXqJeL/kOI=";
            };
          }
        );
      }
    );
  };
}
