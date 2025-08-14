{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.ghostty = {
    enable = lib.mkDefault (
      config.garden.profiles.graphical.enable && config.garden.programs.defaults.terminal == "ghostty"
    );

    # FIXME: ghostty is broken on darwin
    package = if pkgs.stdenv.hostPlatform.isLinux then pkgs.ghostty else null;

    settings = {
      command = "/etc/profiles/per-user/robin/bin/zsh --login";

      background-opacity = 0.92;
      cursor-style = "bar";
      window-padding-x = "4";
      window-padding-y = "0";
      window-padding-balance = true;
      window-decoration = toString pkgs.stdenv.hostPlatform.isDarwin;
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = config.garden.style.fonts.name;
      font-size = 13;
      font-feature = builtins.concatStringsSep "," [
        "zero"
        "cv01" # `@ $ & % Q => ->` without gap

        # consistent style
        # "cv33" # italic `i` j with left bottom bar and horizen top bar, just like regular style

        # no tails
        "cv34" # italic `k` without circle, just like regular style
        "cv35" # italic `l` without tail, just like regular style
        # "cv36" # italic `x` without tails, just like regular style
        # "ss06" # Break connected strokes between italic letters (al, ul, il ...)

        # disable ligatures
        "ss01" # Broken equals ligatures (==, ===, !=, !==, =/=)
        "ss02" # Broken compare and equal ligatures (<=, >=)
        "ss04" # Break multiple underscores (__, #__)

        "ss03" # Enable arbitrary tag (allow to use any case in all tags)

        "ss05" # Thin backslash in escape letters (\w, \n, \r ...)

        "ss07" # Relax the conditions for multiple greaters ligatures (>> or >>>)
        # "ss08" # Enable double headed arrows and reverse arrows (>>=, -<<, ->>, >- ...)
      ];

      adjust-cell-height = "20%";
    };
  };
}
