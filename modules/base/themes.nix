{ lib, pkgs, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) str int package;
in
{
  options.garden.style.font = {
    name = mkOption {
      type = str;
      description = "The name of the font";
      default = "Maple Mono";
    };

    italic = mkOption {
      type = str;
      description = "The name of the italic font";
      default = "Maple Mono Italic";
    };

    bold = mkOption {
      type = str;
      description = "The name of the bold font";
      default = "Maple Mono Bold";
    };

    bold-italic = mkOption {
      type = str;
      description = "The name of the bold italic font";
      default = "Maple Mono Bold Italic";
    };

    package = mkOption {
      type = package;
      description = "The package that provides the font";
      default = pkgs.maple-mono.truetype;
    };

    size = mkOption {
      type = int;
      description = "The size of the font";
      default = 14;
    };
  };
}
