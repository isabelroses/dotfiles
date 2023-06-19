{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.btop];

  programs.btop = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      # color_theme = "catppuccin_mocha";
      vim_keys = true;
      rounded_corners = true;
    };
  };
}
