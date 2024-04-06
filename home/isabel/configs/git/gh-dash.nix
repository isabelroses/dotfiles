{
  programs.gh-dash = {
    enable = true;
  };

  xdg.configFile."gh-dash/config.yml".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/isabelroses/gh-dash/main/themes/mocha/pink.yml";
    sha256 = "0yk4qpprhkyg9k3xjh2fsil5a815jr3ssfi61d5pw43lhkwm5f99";
  };
}
