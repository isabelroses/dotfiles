{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xfce.thunar
    gvfs
  ];
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
}
