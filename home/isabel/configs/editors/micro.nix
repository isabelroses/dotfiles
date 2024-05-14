{ lib, osConfig, ... }:
{
  config = lib.mkIf osConfig.modules.programs.agnostic.editors.micro.enable {
    programs.micro = {
      enable = true;
      settings = {
        "autosu" = true;
        "clipboard" = "terminal";
        "eofnewline" = false;
        "savecursor" = true;
        "statusformatl" = "$(filename) @($(line):$(col)) $(modified)| $(opt:filetype) $(opt:encoding)";
      };
    };
  };
}
