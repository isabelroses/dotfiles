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
  config = lib.mkIf osConfig.garden.programs.gui.terminals.wezterm.enable {
    programs.wezterm = {
      enable = true;
      package = inputs'.beapkgs.packages.wezterm;
    };

    xdg.configFile =
      let
        symlink =
          fileName:
          {
            recursive ? false,
          }:
          {
            source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/${fileName}";
            inherit recursive;
          };
      in
      {
        # https://github.com/nix-community/home-manager/issues/1807#issuecomment-1740960646
        "wezterm/wezterm.lua".enable = false;
        "wezterm" = symlink "home/${system.mainUser}/configs/gui/terminals/wezterm" { recursive = true; };
      };
  };
}
