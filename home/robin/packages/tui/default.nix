{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = osConfig.garden.programs;
in
{
  imports = [
    ./btop.nix
    ./izrss.nix
    # ./newsboat.nix
    # ./ranger.nix
    ./yazi
    # ./zellij.nix
  ];

  config = mkIf cfg.tui.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        # wishlist # fancy ssh
        glow # fancy markdown
        # fx # fancy jq
        gum # a nicer scripting
        ;

      inherit (inputs'.beapkgs.packages) zzz; # code snippets in the cli
    };
  };
}
