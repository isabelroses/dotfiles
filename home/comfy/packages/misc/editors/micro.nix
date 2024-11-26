{ lib, osConfig, ... }:
{
  programs.micro = lib.modules.mkIf osConfig.garden.programs.micro.enable {
    enable = true;
    settings = {
      "autosu" = true;
      "clipboard" = "terminal";
      "eofnewline" = false;
      "savecursor" = true;
      "statusformatl" = "$(filename) @($(line):$(col)) $(modified)| $(opt:filetype) $(opt:encoding)";
    };
  };
}
