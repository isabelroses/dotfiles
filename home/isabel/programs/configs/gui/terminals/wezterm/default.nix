{
  config,
  osConfig,
  lib,
  inputs',
  ...
}: let
  inherit (osConfig.modules) environment system;
in {
  config = lib.mkIf osConfig.modules.programs.gui.terminals.wezterm.enable {
    programs.wezterm = {
      enable = true;
      package = inputs'.wezterm.packages.default;
    };

    xdg.configFile = let
      symlink = fileName: {recursive ? false}: {
        source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/${fileName}";
        inherit recursive;
      };
    in {
      # https://github.com/nix-community/home-manager/issues/1807#issuecomment-1740960646
      "wezterm/wezterm.lua".enable = false;
      "wezterm" = symlink "home/${system.mainUser}/programs/configs/gui/terminals/wezterm" {
        recursive = true;
      };
    };
  };
}
