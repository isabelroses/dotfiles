{
  lib,
  config,
  defaults,
  ...
}: {
  config = lib.mkIf (defaults.editor == "micro") {
    programs.micro = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        "autosu" = true;
        "clipboard" = "terminal";
        "colorscheme" = "catppuccin-mocha";
        "eofnewline" = false;
        "savecursor" = true;
        "statusformatl" = "$(filename) @($(line):$(col)) $(modified)| $(opt:filetype) $(opt:encoding)";
      };
    };
  };
}
