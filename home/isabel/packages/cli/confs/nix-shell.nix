{
  pkgs,
  inputs,
  ...
}: 
let
  programs = osConfig.modules.programs;
  device = osConfig.modules.device;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (programs.cli.enable)) {
    home = {
      packages = with pkgs; [
        alejandra
        deadnix
        nix-index
        statix
      ];

      sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
