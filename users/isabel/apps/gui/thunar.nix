{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xfce.thunar
    gvfs
  ];
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };
}
