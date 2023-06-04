{
  config,
  pkgs,
  ...
}: {
  xdg.configFile."btop/themes/catppuccin_mocha.theme".text = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "btop";
      rev = "ecb8562bb6181bb9f2285c360bbafeb383249ec3";
      sha256 = "sha256-ovVtupO5jWUw6cwA3xEzRe1juUB8ykfarMRVTglx3mk=";
    }
    + "/catppuccin_mocha.theme");

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
      vim_keys = true;
      rounded_corners = true;
    };
  };
}