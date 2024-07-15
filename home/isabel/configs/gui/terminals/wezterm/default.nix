{
  lib,
  config,
  inputs',
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) environment system;
in
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.terminals.wezterm.enable {
    programs.wezterm = {
      enable = true;
      package = inputs'.beapkgs.packages.wezterm;
    };

    xdg.configFile = {
      # to fix a issue where "wezterm/wezterm.lua" is created 2 times making a breakage 
      # we disable it, and then create a symlink to the correct file
      # this could also be fixed by not using the wezterm modules!
      # https://github.com/nix-community/home-manager/issues/1807#issuecomment-1740960646
      "wezterm/wezterm.lua".enable = false;
      "wezterm" = {
        source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/home/${system.mainUser}/configs/gui/terminals/wezterm";
        recursive = true;
      };
    };
  };
}
