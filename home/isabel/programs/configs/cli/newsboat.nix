{
  programs.newsboat = {
    enable = true;
    autoReload = true;
    maxItems = 0;

    urls = [
      {
        title = "Uncenter";
        tags = ["webdev" "friends"];
        url = "https://uncenter.dev/feed.xml";
      }
      {
        title = "Me";
        tags = ["me"];
        url = "https://isabelroses.com/rss.xml";
      }
      {
        title = "antfu";
        tags = ["webdev"];
        url = "https://antfu.me/feed.xml";
      }
      {
        title = "fasterthenli";
        tags = ["webdev" "rust" "nix"];
        url = "https://fasterthanli.me/index.xml";
      }
      {
        title = "orhun";
        tags = ["rust" "linux"];
        url = "https://blog.orhun.dev/rss.xml";
      }
      {
        title = "mitchellh";
        tags = ["terminal"];
        url = "https://mitchellh.com/feed.xml";
      }
      {
        title = "solene";
        tags = ["linux" "bsd" "nix"];
        url = "https://dataswamp.org/~solene/rss.xml";
      }
      {
        title = "viperml";
        tags = ["nix"];
        url = "https://ayats.org/index.xml";
      }
    ];

    extraConfig = ''
      color listnormal         color15 default
      color listnormal_unread  color2  default
      color listfocus_unread   color2  color0
      color listfocus          default color0
      color background         default default
      color article            default default
      color end-of-text-marker color8  default
      color info               color4  color8
      color hint-separator     default color8
      color hint-description   default color8
      color title              color14 color8

      highlight article "^(Feed|Title|Author|Link|Date): .+" color4 default bold
      highlight article "^(Feed|Title|Author|Link|Date):" color14 default bold

      highlight article "\\((link|image|video)\\)" color8 default
      highlight article "https?://[^ ]+" color4 default
      highlight article "\[[0-9]+\]" color6 default bold

      refresh-on-startup yes
    '';
  };
}
