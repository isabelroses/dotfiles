{
  pkgs,
  config, 
  ...
}: {
  xdg.configFile."nvim".source = ../../config/nvim;
  
  home.packages = with pkgs; [
    neovim-unwrapped
  ];
  
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    vimAlias = true;
    viAlias = false;
    vimdiffAlias = false;
    withRuby = false;
    withNodeJs = false;
    withPython3 = false;
  };
}
