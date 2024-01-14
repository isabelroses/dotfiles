{
  pkgs,
  lib,
  osConfig,
  defaults,
  ...
}: let
  inherit (lib) mkIf isWayland;
in {
  config = mkIf (isWayland osConfig && defaults.screenLocker == "swaylock") {
    home.packages = with pkgs; [swaylock-effects];

    programs.swaylock = {
      enable = true;
      package = with pkgs; swaylock-effects;
      settings = {
        ignore-empty-password = true;
        show-failed-attempts = true;
        clock = true;
        indicator-radius = 120;
        indicator-thickness = 20;
        line-uses-ring = true;
        font = "RobotoMono Nerd Font Regular";
        font-size = 32;
        color = "11111bff";
        separator-color = "3132441c";
        key-hl-color = "89b4fa80";
        bs-hl-color = "b4befe80";
        text-caps-lock-color = "74c7ecff";
        text-color = "89b4fa3eff";
        inside-color = "1e1e2e1c";
        ring-color = "89b4fa3e";
        line-color = "11111b00";
        text-clear-color = "a6e3a1ff";
        inside-clear-color = "1e1e2e1c";
        ring-clear-color = "a6e3a13e";
        line-clear-color = "11111b00";
        text-ver-color = "f9e2afff";
        inside-ver-color = "1e1e2e1c";
        ring-ver-color = "f9e2af3e";
        line-ver-color = "11111b00";
        text-wrong-color = "f38ba8ff";
        inside-wrong-color = "1e1e2e1c";
        ring-wrong-color = "f38ba855";
        line-wrong-color = "11111b00";
      };
    };
  };
}
