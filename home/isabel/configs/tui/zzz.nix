{
  lib,
  inputs',
  osConfig,
  ...
}:
{
  config = lib.modules.mkIf osConfig.garden.programs.tui.enable {
    home.packages = [ inputs'.beapkgs.packages.zzz ];

    xdg.configFile."zzz/config.yaml".text = ''
      default_language: go
    '';
  };
}
