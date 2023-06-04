{
  pkgs,
  config, 
  ...
}: {
  xdg.configFile."nvim".source = ../config/nvim;
  
  home.packages = with pkgs; [
    neovim-unwrapped
    stylua
    nodePackages_latest.prettier
    black
    alejandra
    shfmt
    # rustfmt is provided by rust-overlay
  
    selene
    nodePackages_latest.eslint_d
    shellcheck
    statix
  
    nodePackages_latest.typescript-language-server
    deno
    nodePackages_latest.bash-language-server
    nodePackages_latest.pyright
    nodePackages_latest.vscode-langservers-extracted
    nodePackages_latest.dockerfile-language-server-nodejs
    rnix-lsp
    rust-analyzer
    gcc

    vimPlugins.packer-nvim
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
