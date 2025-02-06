{
  lib,
  pkgs,
  self,
  inputs',
  config,
  ...
}:
let
  inherit (self.lib.hardware) ldTernary;
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;
in
{
  imports = [ self.homeManagerModules.hyfetch ];
  disabledModules = [ "programs/hyfetch.nix" ];

  programs.hyfetch = mkIf (isModernShell config) {
    enable = true;
    package = inputs'.beapkgs.packages.hyfetch;

    settings = {
      preset = "lesbian";
      mode = "rgb";
      light_dark = "dark";
      lightness = 0.56;
      color_align = {
        mode = "horizontal";
        custom_colors = [ ];
        fore_back = null;
      };
      backend = "fastfetch";
      distro = ldTernary pkgs "nixos_small" "macos_small";
      pride_month_shown = [ ];
      pride_month_disable = true;
    };

    fastfetchConfig = {
      logo = {
        type = "small";
        padding.top = 1;
      };
      display.separator = " ";
      modules = [
        {
          key = "╭───────────╮";
          type = "custom";
        }
        {
          key = "│ {#35} kernel  {#keys}│";
          type = "kernel";
        }
        {
          key = "│ {#34}{icon} distro  {#keys}│";
          type = "os";
        }
        {
          key = "│ {#36} wm {#keys}│";
          type = "de";
        }
        {
          key = "│ {#32} shell   {#keys}│";
          type = "shell";
        }
        {
          key = "│ {#31} term    {#keys}│";
          type = "terminal";
        }
        {
          key = "│ {#35}󰍛 memory  {#keys}│";
          type = "memory";
        }
        {
          key = "│ {#33}󰔛 uptime  {#keys}│";
          type = "uptime";
        }
        {
          key = "├───────────┤";
          type = "custom";
        }
        {
          key = "│ {#39} colors  {#keys}│";
          type = "colors";
          symbol = "circle";
        }
        {
          key = "╰───────────╯";
          type = "custom";
        }
      ];
    };
  };
}
