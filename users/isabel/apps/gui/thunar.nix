{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    xfce.thunar 
  ];
  #programs.thunar = {
  #  enable = true;
  #  plugins = with pkgs.xfce; [
  #    thunar-archive-plugin
  #    thunar-volman
  #    thunar-media-tags-plugin
  #  ];
  #};
  #services.gvfs.enable = true;
  #services.tumbler.enable = true;
}
