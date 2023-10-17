{
  config,
  pkgs,
  osConfig,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig.modules) programs;
in {
  imports = [
    ./confs
  ];

  config = mkIf (programs.tui.enable) {
    home.packages = with pkgs; [
      wishlist # fancy ssh
      glow # fancy markdown
    ];
  };
}
