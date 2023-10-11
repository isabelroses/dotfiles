{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  programs = osConfig.modules.programs;
in {
  config = mkIf (programs.cli.enable) {
    home.packages = with pkgs;
      [
        # CLI packages from nixpkgs
        unzip
        ripgrep
        rsync
        fd
        jq
        dconf
        nitch
        exa
      ]
      ++ optionals (programs.nur.enable && programs.nur.bella) [
        nur.repos.bella.bellado
        nur.repos.bella.catppuccinifier-cli
      ];
  };
}
