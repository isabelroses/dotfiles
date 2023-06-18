{
  osConfig,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
with lib; let
  programs = osConfig.modules.programs;
in {
  config = (mkIf programs.cli.enable) {
    home.packages = with pkgs; [
      # CLI packages from nixpkgs
      unzip
      ripgrep
      rsync
      fd
      jq
      dconf
      nitch
      exa
      git-lfs
    ];
  };
}
