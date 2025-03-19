{
  lib,
  pkgs,
  inputs',
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;

  cfg = config.garden.programs;
in
{
  imports = [
    ./btop.nix
    ./izrss.nix
    # ./newsboat.nix
    # ./yazi.nix
    # ./zellij.nix
  ];

  config = mkIf cfg.tui.enable {
    garden.packages =
      {
        inherit (pkgs)
          # wishlist # fancy ssh
          glow # fancy markdown
          # fx # fancy jq
          # gum # a nicer scripting
          ;

        inherit (inputs'.tgirlpkgs.packages) zzz; # code snippets in the cli
      }
      // optionalAttrs cfg.gui.enable {
        inherit (pkgs) manga-tui; # tui manga finder + reader
      };
  };
}
