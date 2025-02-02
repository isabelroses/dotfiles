{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.evergarden) palette;

  mkFg = fg: { fg = "#${fg}"; };
  mkBg = bg: { bg = "#${bg}"; };
  mkBoth = fg: bg: (mkFg fg) // (mkBg bg);
  mkSame = c: mkBoth c c;

  mkRule = mime: fg: (mkFg fg) // { inherit mime; };
in
{
  programs.yazi.theme = {
    manager =
      let
        active = mkBoth palette.text palette.surface0;
      in
      {
        syntect_theme = pkgs.writeTextFile {
          name = "syntax-evergarden";
          text = lib.template.textmate palette;
        };

        cwd = mkFg palette.aqua;
        hovered = active;
        preview_hovered = active;
        find_keyword = mkFg palette.green;
        find_position = mkFg palette.text;
        marker_selected = mkSame palette.green;
        marker_copied = mkSame palette.yellow;
        marker_cut = mkSame palette.red;
        tab_active = mkBoth palette.base palette.green;
        tab_inactive = mkBoth palette.surface2 palette.subtext1;
        border_style = mkFg palette.surface2;
      };

    mode = {
      normal_main = mkBoth palette.base palette.green;
      normal_alt = mkBoth palette.base palette.green;
      select_main = mkBoth palette.base palette.purple;
      select_alt = mkBoth palette.purple palette.base;
      unset_main = mkBoth palette.base palette.overlay1;
      unset_alt = mkBoth palette.overlay1 palette.base;
    };

    status = {
      separator_style = mkSame palette.surface0;
      progress_label = mkBoth palette.text palette.base;
      progress_normal = mkBoth palette.text palette.base;
      progress_error = mkBoth palette.red palette.base;
      permissions_t = mkFg palette.blue;
      permissions_r = mkFg palette.yellow;
      permissions_w = mkFg palette.purple;
      permissions_x = mkFg palette.green;
      permissions_s = mkFg palette.aqua;
    };

    select = {
      border = mkFg palette.green;
      active = mkFg palette.pink;
      inactive = mkFg palette.text;
    };

    input = {
      border = mkFg palette.green;
      title = mkFg palette.text;
      value = mkFg palette.text;
      selected = mkBg palette.surface0;
    };

    completion = {
      border = mkFg palette.green;
      active = mkBoth palette.pink palette.surface0;
      inactive = mkFg palette.text;
    };

    tasks = {
      border = mkFg palette.green;
      title = mkFg palette.text;
      hovered = mkBoth palette.text palette.surface0;
    };

    which = {
      mask = mkBg palette.surface2;
      cand = mkFg palette.aqua;
      rest = mkFg palette.overlay0;
      desc = mkFg palette.text;
      separator_style = mkFg palette.overlay1;
    };

    help = {
      on = mkFg palette.pink;
      run = mkFg palette.aqua;
      desc = mkFg palette.text;
      hovered = mkBoth palette.text palette.surface0;
      footer = mkFg palette.text;
    };

    # https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/theme.toml
    filetype.rules = [
      (mkRule "image/*" palette.aqua)
      (mkRule "video/*" palette.yellow)
      (mkRule "audio/*" palette.yellow)

      (mkRule "application/zip" palette.pink)
      (mkRule "application/gzip" palette.pink)
      (mkRule "application/x-tar" palette.pink)
      (mkRule "application/x-bzip" palette.pink)
      (mkRule "application/x-bzip2" palette.pink)
      (mkRule "application/x-7z-compressed" palette.pink)
      (mkRule "application/x-rar" palette.pink)
      (mkRule "application/xz" palette.pink)

      (mkRule "application/doc" palette.green)
      (mkRule "application/pdf" palette.green)
      (mkRule "application/rtf" palette.green)
      (mkRule "application/vnd.*" palette.green)

      ((mkRule "inode/directory" palette.overlay2) // { bold = true; })
      (mkRule "*" palette.subtext1)
    ];
  };
}
